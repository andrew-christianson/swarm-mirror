// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import "internal.h"
#import "global.h"

#include <tk.h>

#ifdef _WIN32
// Get a definition of timeval, but avoid redefinition of timezone.
#define timezone timezone__
#include <sys/time.h>
#undef timezone
// Undo X11 definition
#undef Status
#include "win32dib.h"
#define BOOL BOOL_
#include "tk/tkInt.h"
#undef BOOL

#define Arguments Win32Arguments
#define Colormap X11Colormap
#include "tk/tkWinInt.h"
#undef Colormap
#undef Arguments
#endif

#import <tkobjc/TkExtra.h>
#import <tkobjc/Pixmap.h> // PixmapError
#import <defobj.h> // Arguments

#include <misc.h>

#ifndef _WIN32
#include "schedule.xpm"
#include "trigger.xpm"
#endif

typedef struct raster_private {
  GC gc;
  Tk_Window tkwin;
#ifndef _WIN32
  X11Pixmap pm;
  X11Pixmap oldpm;
  BOOL privateColormapFlag;
#else
  dib_t *oldpm;
  dib_t *pm;
#endif
} raster_private_t;

extern TkExtra *globalTkInterp;

Tk_Window 
tkobjc_nameToWindow (const char *widgetName)
{
  return Tk_NameToWindow ([globalTkInterp interp],
                          (char *)widgetName,
                          [globalTkInterp mainWindow]);
}

void
tkobjc_setName (id widget, const char *name)
{
  const char *prefix = "Swarm";
  const char *appName = [arguments getAppName];
  const char *appModeString = [arguments getAppModeString];
  char buf[(strlen (prefix) + 1 + strlen (appName) + 1 +
            strlen (appModeString) + 1)];
  
  Tk_Window tkwin = tkobjc_nameToWindow ([[widget getTopLevel] getWidgetName]);
  
  if (name)
    Tk_Name (tkwin) = (char *)name;
  stpcpy (stpcpy (stpcpy
                  (stpcpy (stpcpy (buf, prefix), "-"),
                   appName), "-"),
          appModeString);

  Tk_SetClass (tkwin, buf);
}

void
tkobjc_unlinkVar (const char *variableName)
{
  Tcl_UnlinkVar ([globalTkInterp interp], (char *)variableName); 
}

void
tkobjc_linkVar (const char *variableName, void *p, int type)
{
  Tcl_LinkVar ([globalTkInterp interp], (char *)variableName, (char *)p, type);
}

static void
registerInterp (void)
{
  [globalTkInterp registerObject: globalTkInterp withName: "globalTkInterp"];
}

static void
setSecondaryPath (id arguments)
{
  const char *swarmHome = [arguments getSwarmHome];
  
  if (swarmHome)
    {
      const char *secondarySubpath = "share/";
      char *libraryPath = xmalloc (strlen (swarmHome) +
                                   strlen (secondarySubpath) + 1);
      char *p;
      
      p = stpcpy (libraryPath, swarmHome);
      p = stpcpy (p, secondarySubpath);
      [globalTkInterp setSecondaryLibraryPath: libraryPath];
    }
}

void
tkobjc_initTclInterp (id arguments)
{
  globalTkInterp = [TclInterp alloc];  // misnomer
  setSecondaryPath (arguments);
  [globalTkInterp initWithArgc: 1 /* [arguments getArgc] */
                  argv: [arguments getArgv]];
  registerInterp ();
}

void
tkobjc_initTkInterp (id arguments)
{
  globalTkInterp = [TkExtra alloc];
  setSecondaryPath (arguments);

  [globalTkInterp initWithArgc: 1 /* [arguments getArgc] */
                  argv: [arguments getArgv]];
  registerInterp ();
}

void
tkobjc_createEventHandler (id widget, Tk_EventProc proc)
{
  Tk_Window tkwin = tkobjc_nameToWindow ([widget getWidgetName]);

  Tk_CreateEventHandler (tkwin, StructureNotifyMask, proc, widget);
}

void
tkobjc_deleteEventHandler (id widget, Tk_EventProc proc)
{
  Tk_Window tkwin = tkobjc_nameToWindow ([widget getWidgetName]);

  Tk_DeleteEventHandler (tkwin, StructureNotifyMask, proc, widget);
}

#ifndef _WIN32
XImage *triggerImage = NULL;
XImage *scheduleImage = NULL;
GC gc;
#else
HBITMAP triggerImage = NULL;
HBITMAP scheduleImage = NULL;
#define ANIMATEDMESSAGE "AnimatedMessage"
#endif

void
tkobjc_animate_message (id srcWidget,
                        id destWidget,
                        int sx, int sy,
                        int dx, int dy,
                        BOOL triggerFlag,
                        unsigned sleepTime)
{
  Tk_Window src_tkwin = tkobjc_nameToWindow ([srcWidget getWidgetName]);
  Tk_Window dest_tkwin = tkobjc_nameToWindow ([destWidget getWidgetName]);
  int nsx, nsy, ndx, ndy;
  unsigned width, height;

#ifndef _WIN32
  Display *display = Tk_Display (src_tkwin);
  Window rootWindow = RootWindowOfScreen (Tk_Screen (src_tkwin));
  Window window;
  XImage *image;

  XFlush (display);
  {
    Window child;
    XTranslateCoordinates (display, 
                           Tk_WindowId (src_tkwin), rootWindow,
                           sx, sy, &nsx, &nsy, &child);
    XTranslateCoordinates (display,
                           Tk_WindowId (dest_tkwin), rootWindow,
                           dx, dy, &ndx, &ndy, &child);
  }
#else
  HWND hwnd; 
  HBITMAP image;

  GdiFlush ();
  
  {
    RECT rect;

    if (!GetWindowRect (TkWinGetHWND (Tk_WindowId (src_tkwin)), &rect))
      abort ();
    nsx = rect.left + sx;
    nsy = rect.top + sy;
    if (!GetWindowRect (TkWinGetHWND (Tk_WindowId (dest_tkwin)), &rect))
      abort ();
    ndx = rect.left + dx;
    ndy = rect.top + dy;
  }
    
#endif
  
#ifndef _WIN32
  if (scheduleImage == NULL)
    {
      XImage *shapemask;
      Screen *screen = Tk_Screen (src_tkwin);
      XpmCreateImageFromData (display, trigger_xpm,
                              &triggerImage, &shapemask, NULL);
      XpmCreateImageFromData (display, schedule_xpm, 
                              &scheduleImage, &shapemask, NULL);
      gc = XCreateGC (display, RootWindowOfScreen (screen), 0, NULL);
    }
  image = triggerFlag ? triggerImage : scheduleImage;
  width = image->width;
  height = image->height;
  {
    XSetWindowAttributes attr;

    attr.override_redirect = True;
    window = XCreateWindow (display, rootWindow, nsx, nsy, width, height, 0,
                            image->depth,
                            InputOutput, CopyFromParent,
                            CWOverrideRedirect, &attr);
    XMapWindow (display, window);
    XPutImage (display, window, gc, image, 0, 0, 0, 0, width, height);
  }
#else
  if (scheduleImage == NULL)
    {
      scheduleImage = LoadImage (NULL, (LPCTSTR)OBM_DNARROW, IMAGE_BITMAP,
				 0, 0, LR_CREATEDIBSECTION);
      if (scheduleImage == NULL)
	abort ();
      triggerImage = LoadImage (NULL, (LPCTSTR)OBM_UPARROW, IMAGE_BITMAP,
				0, 0, LR_CREATEDIBSECTION);
      if (triggerImage == NULL)
	abort ();
      {
	WNDCLASS wndclass;

	wndclass.style = CS_NOCLOSE;
	wndclass.lpfnWndProc = DefWindowProc;
	wndclass.cbClsExtra = 0;
	wndclass.cbWndExtra = 0;
	wndclass.hInstance = Tk_GetHINSTANCE ();
	wndclass.hIcon = NULL;
	wndclass.hCursor = NULL;
	wndclass.hbrBackground = NULL;
	wndclass.lpszMenuName = NULL;
	wndclass.lpszClassName = ANIMATEDMESSAGE;
	if (RegisterClass (&wndclass) == 0)
	  abort();
      }
    }
  image = triggerFlag ? triggerImage : scheduleImage;
  {
    BITMAP bitmap;

    GetObject (image, sizeof (bitmap), (LPVOID)&bitmap);
    width = bitmap.bmWidth;
    height = bitmap.bmHeight;
  }
  
  hwnd = CreateWindow (ANIMATEDMESSAGE, "Message Window", 
		       WS_POPUP, nsx, nsy, width, height,
		       HWND_DESKTOP, NULL, 
		       Tk_GetHINSTANCE (), NULL);
  if (hwnd == NULL)
    abort ();
#endif
  {
    double stepFactor = 2.0;
    int xstep = width * stepFactor;
    int ystep = height * stepFactor;
    if (xstep == 0)
      xstep = 1;
    if (ystep == 0)
      ystep = 1;
    {
      int xdiff = ndx - nsx;
      int ydiff = ndy - nsy;
      unsigned xdist = xdiff < 0 ? -xdiff : xdiff;
      unsigned ydist = ydiff < 0 ? -ydiff : ydiff;
      unsigned xsteps =  xdist / xstep;
      unsigned ysteps = ydist / ystep;
      unsigned steps = ((xsteps > ysteps) ? xsteps : ysteps);
      int x = nsx;
      int y = nsy;
      unsigned i;

      if (steps == 0)
	steps = 1;
      xstep = xdiff / (int)steps;
      ystep = ydiff / (int)steps;
      if (xstep == 0)
        xstep = 1;
      if (ystep == 0)
        ystep = 1;
    
      for (i = 0; i < steps; i++)
        {
#ifndef _WIN32
          XMoveWindow (display, window, x, y);
#else
	  SetWindowPos (hwnd,
			HWND_TOPMOST, x, y, 0, 0,
			SWP_NOSIZE | SWP_SHOWWINDOW);

	  {
	    HDC destDC = GetDC (hwnd);
	    HDC sourceDC = CreateCompatibleDC (destDC);
	    
	    SelectObject (sourceDC, image);
	    if (BitBlt (destDC, 0, 0, width, height, sourceDC, 0, 0, SRCCOPY)
		== FALSE)
	      abort ();
	    DeleteDC (sourceDC);
	  }
#endif
          if (triggerFlag && sleepTime)
            Tcl_Sleep (sleepTime);
          while (Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT));
#ifndef _WIN32
          XFlush (display);
#else
	  GdiFlush ();
#endif
          x += xstep;
          y += ystep;
        }
    }
  }
#ifndef _WIN32
  XDestroyWindow (display, window);
#else
  DestroyWindow (hwnd);
#endif
}

void
tkobjc_move (id widget, int x, int y)
{
  Tk_MoveToplevelWindow (tkobjc_nameToWindow ([[widget getTopLevel]
                                                getWidgetName]),
                         x, y);
}

#ifndef _WIN32
static void
Xfill (Display *display, GC gc, X11Pixmap pm,
       int x, int y,
       unsigned width, unsigned height,
       PixelValue pixel)
{
#if 0
  XGCValues oldgcv;
  
  XGetGCValues (display, gc, GCForeground, &oldgcv);  // save old colour
#endif
  XSetForeground (display, gc, pixel); // no checking on map.
  XFillRectangle (display, pm, gc, x, y, width, height);
  
#if 0
  XChangeGC (display, gc, GCForeground, &oldgcv);
#endif
}
#endif

void
tkobjc_raster_create (Raster *raster)
{
  Tk_Window tkwin = tkobjc_nameToWindow ([raster getWidgetName]);

  if (tkwin == NULL)
    raiseEvent (WindowCreation, "Error creating tkwin!\n%s",
                [globalTkInterp result]);
  else
    {
      raster_private_t *private = xmalloc (sizeof (raster_private_t));

      Tk_MakeWindowExist (tkwin);
#ifndef _WIN32
      private->privateColormapFlag = NO;
#endif
      private->tkwin = tkwin;
      raster->private = private;
    }
}

void
tkobjc_raster_erase (Raster *raster)
{
#ifndef _WIN32
  raster_private_t *private = raster->private;
  Display *display = Tk_Display (private->tkwin);
  
  Xfill (display, private->gc, private->pm,
         0, 0, raster->width, raster->height,
         BlackPixel (display, DefaultScreen (display)));
#else
  Colormap *colormap = raster->colormap;

  if (colormap)
    [raster fillRectangleX0: 0 Y0: 0
            X1: [raster getWidth] Y1: [raster getHeight]
            Color: raster->eraseColor];
#endif
}

void
tkobjc_raster_fillRectangle (Raster *raster,
                             int x, int y,
                             unsigned width, unsigned height,
			     Color color)
{
  raster_private_t *private = raster->private;

#ifndef _WIN32
  PixelValue *map = ((Colormap *)raster->colormap)->map;
  
  Xfill (Tk_Display (private->tkwin), private->gc, private->pm,
         x, y, width, height,
         map[color]);
#else
  dib_fill (private->pm, x, y, width, height, color);
#endif
}

void
tkobjc_raster_ellipse (Raster *raster,
		       int x, int y,
		       unsigned width, unsigned height,
		       unsigned pixels,
		       Color color)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  PixelValue *map = ((Colormap *)raster->colormap)->map;
  Display *display = Tk_Display (private->tkwin);
  GC gc = private->gc;

  XSetForeground (display, gc, map[color]);
  XDrawArc (display, private->pm, gc, x, y, width, height, 0, 23040);
#else
  dib_ellipse (private->pm, x, y, width, height, pixels, color);
#endif
}

void
tkobjc_raster_line (Raster *raster,
                    int x0, int y0,
                    int x1, int y1,
                    unsigned pixels,
                    Color color)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  PixelValue *map = ((Colormap *) raster->colormap)->map;
  Display *display = Tk_Display (private->tkwin);
  GC gc = private->gc;

  XSetForeground (display, gc, map[color]);
  XSetLineAttributes (display, gc, pixels, LineSolid, CapButt, JoinRound);
  XDrawLine (display, private->pm, gc, x0, y0, x1, y1);
#else
  dib_line (private->pm, x0, y0, x1, y1, pixels, color);
#endif
}

void
tkobjc_raster_rectangle (Raster *raster,
                         int x, int y,
                         unsigned width, unsigned height,
                         unsigned pixels,
                         Color color)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  PixelValue *map = ((Colormap *) raster->colormap)->map;
  Display *display = Tk_Display (private->tkwin);
  GC gc = private->gc;

  XSetForeground (display, gc, map[color]);
  XSetLineAttributes (display, gc, pixels, LineSolid, CapButt, JoinRound);
  XDrawRectangle (display, private->pm, gc, x, y, width, height);
#else
  dib_rectangle (private->pm, x, y, width, height, pixels, color);
#endif
}

void
tkobjc_raster_drawPoint (Raster *raster, int x, int y, Color c)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  PixelValue *map = ((Colormap *)raster->colormap)->map;
  X11Pixmap pm = private->pm;
  Display *display = Tk_Display (private->tkwin);
  GC gc = private->gc;

  XSetForeground (display, gc, map[c]);    // no checking on map.

  XDrawPoint (display, pm, gc, x, y);
#else
  dib_t *dib = private->pm;
  int frameWidth = dib->dibInfo->bmiHead.biWidth;
  int frameHeight = (dib->dibInfo->bmiHead.biHeight < 0
		     ? -dib->dibInfo->bmiHead.biHeight
		     : dib->dibInfo->bmiHead.biHeight);

  if (x >= 0 && x < frameWidth
      && y >= 0 && y < frameHeight)
    {
      WORD depth = dib->dibInfo->bmiHead.biBitCount;

      if (depth == 8)
	((LPBYTE)dib->bits)[x + y * frameWidth] = c;
      else if (depth == 24)
	{
	  LPBYTE rgb = (LPBYTE)dib->bits + (x + y * frameWidth * 3);
	  unsigned long colorValue = dib->colormap[c];

	  rgb[2] = colorValue >> 16;
	  rgb[1] = (colorValue >> 8) && 0xff;
	  rgb[0] = colorValue & 0xff;
	}
    }
#endif
}

void
tkobjc_raster_createContext (Raster *raster)
{
  raster_private_t *private = raster->private;
  XGCValues gcv;
  Display *display = Tk_Display (private->tkwin);
  Window xwin = Tk_WindowId (private->tkwin);
  GC gc;

  // now create a GC
  gcv.background = BlackPixel (display, DefaultScreen (display));
  gcv.graphics_exposures = False;
  gc = XCreateGC (display, xwin, GCBackground | GCGraphicsExposures, &gcv);
  XSetFillStyle (display, gc, FillSolid);
  XSetClipOrigin (display, gc, 0, 0);
  private->gc = gc;
}

BOOL
tkobjc_setColor (Colormap *colormap, const char *colorName, PixelValue *pvptr)
{
  int rc;
  XColor sxc;
  Display *display = Tk_Display (colormap->tkwin);
  int screen = DefaultScreen (display);

#ifndef _WIN32
  XColor exc;
  rc = XLookupColor (display, colormap->cmap, colorName, &exc, &sxc);
#else
  rc = XParseColor (display, colormap->cmap, colorName, &sxc);
#endif
  if (!rc)
    {
      raiseEvent (ResourceAvailability, 
                  "Problem locating color %s. Substituting white.\n",
                  colorName);
      *pvptr = WhitePixel (display, screen);
      return NO;
    }
  for (;;)
    {
      rc = XAllocColor (display, colormap->cmap, &sxc);
      if (rc)
        break;
#ifndef _WIN32
      raiseEvent (ResourceAvailability, 
                  "Problem allocating color %s.  Switching to virtual colormap.\n",
                  colorName);
      colormap->cmap = XCopyColormapAndFree (display, colormap->cmap);
#else
      raiseEvent (ResourceAvailability, 
                  "Problem allocating color %s.  Substituting white.\n",
                  colorName);
      *pvptr = WhitePixel (display, screen);
      return NO;
#endif
    }
  *pvptr = sxc.pixel;
  return YES;
}
  
#ifndef _WIN32
static Window
x_get_managed_toplevel_window (Display *display, Window window)
{
  Window parent, w;
  int cnt = 0;

  for (w = window; cnt == 0; w = parent)
    {
      Window root;
      Window *children;
      int child_cnt;
      Atom *protocols;
      
      if (!XQueryTree (display, w, &root, &parent,
                       &children, &child_cnt))
        abort ();
      XFree (children);
      if (parent == root)
        return 0;
      
      if (XGetWMProtocols (display, parent, &protocols, &cnt))
        XFree (protocols);
    }
  return parent;
}

static void
x_set_private_colormap (Display *display, Window window, X11Colormap cmap)
{
  Window topWindow;
  
  topWindow = x_get_managed_toplevel_window (display, window);

  if (topWindow)
    {
      int cnt;
      Window *colormapWindows;
      
      XSetWindowColormap (display, topWindow, cmap);
      
      if (!XGetWMColormapWindows (display, topWindow,
                                  &colormapWindows, &cnt))
        cnt = 0;
      {
        Window newColormapWindows[cnt + 1];

        if (cnt > 0)
          memcpy (newColormapWindows, colormapWindows, sizeof (Window) * cnt);
        newColormapWindows[cnt] = window;
        if (!XSetWMColormapWindows (display, 
                                    topWindow,
                                    newColormapWindows,
                                    cnt + 1))
          abort ();
      }
      if (cnt > 0)
        XFree (colormapWindows);
    }
  else
    raiseEvent (WarningMessage, "Could not get top window");
}
#endif

void
tkobjc_raster_setColormap (Raster *raster)
{
  Colormap *colormap = raster->colormap;

  if (colormap == nil)
    raiseEvent (WarningMessage, "colormap is nil");
  else
    {
      if (raster->eraseColor == -1)
	{
	  raster->eraseColor = [colormap nextFreeColor];
	  
	  [colormap setColor: raster->eraseColor ToName: "black"];
	}
      {
	raster_private_t *private = raster->private;
#ifdef _WIN32
	dib_t *dib = private->pm;
	
	dib_augmentPalette (dib,
			    raster,
			    [colormap nextFreeColor],
			    colormap->map);
#else
	Tk_Window tkwin = private->tkwin;
	Display *display = Tk_Display (tkwin);
	Window window = Tk_WindowId (tkwin);
        
        if (private->privateColormapFlag == NO)
          {
            X11Colormap cmap = colormap->cmap;
            
            if (cmap != DefaultColormap (display, DefaultScreen (display)))
              {
                while (Tk_DoOneEvent (TK_ALL_EVENTS|TK_DONT_WAIT));
                x_set_private_colormap (display, window, colormap->cmap);
              }
            private->privateColormapFlag = YES;
          }
#endif
      }
    }
}

void
tkobjc_raster_createPixmap (Raster *raster)
{
  raster_private_t *private = raster->private;
  Tk_Window tkwin = private->tkwin;
#ifndef _WIN32
  // and create a local Pixmap for drawing
  private->pm = XCreatePixmap (Tk_Display (tkwin),
                               Tk_WindowId (tkwin),
                               raster->width,
                               raster->height,
                               Tk_Depth (tkwin));
#else
  dib_t *dib = dib_create ();
  
  private->pm = dib;

  dib_createBitmap (dib, TkWinGetHWND (Tk_WindowId (tkwin)),
		    raster->width, raster->height);
#endif
}

void
tkobjc_raster_setBackground (Raster *raster, PixelValue color)
{
  XGCValues gcv;
  raster_private_t *private = raster->private;

  gcv.background = color;
  XChangeGC (Tk_Display (private->tkwin), private->gc, GCBackground, &gcv);
}

void
tkobjc_raster_flush (Raster *raster)
{
  raster_private_t *private = raster->private;
  Tk_Window tkwin = private->tkwin;
#ifndef _WIN32
  Display *display = Tk_Display (tkwin);

  XCopyArea (display, private->pm, Tk_WindowId (tkwin), private->gc,
             0, 0, raster->width, raster->height, 0, 0);
  XFlush (display); 
#else
  TkWinDrawable *twdPtr = (TkWinDrawable *)Tk_WindowId (tkwin);
  dib_t *dib = (dib_t *)private->pm;
  
  dib_paintBlit (dib, GetDC (twdPtr->window.handle),
		 0, 0, 0, 0, raster->width, raster->height);
#endif
}

void
tkobjc_raster_clear (Raster *raster, unsigned oldWidth, unsigned oldHeight)
{
#ifdef _WIN32
  raster_private_t *private = raster->private;
  Tk_Window tkwin = private->tkwin;
  Display *display = Tk_Display (tkwin);
  Window w = Tk_WindowId (tkwin);
  HPALETTE oldPalette, palette;
  HBRUSH brush;
  HWND hwnd = TkWinGetHWND (w);
  RECT rc;
  HDC dc = GetDC (hwnd);
  TkWindow *winPtr;
  unsigned newWidth;
  unsigned newHeight;

  palette = TkWinGetPalette (display->screens[0].cmap);
  oldPalette = SelectPalette (dc, palette, FALSE);

  winPtr = TkWinGetWinPtr (w);
  brush = CreateSolidBrush (winPtr->atts.background_pixel);
  GetWindowRect (hwnd, &rc);
  newWidth = rc.right - rc.left;
  newHeight = rc.bottom - rc.top;

  if (newWidth > oldWidth)
    {
      rc.right = newWidth;
      rc.left = oldWidth;
      rc.bottom = rc.bottom - rc.top;
      rc.top = 0;
      FillRect (dc, &rc, brush);
    }
  if (newHeight > oldHeight)
    {
      rc.right = oldWidth;
      rc.left = 0;
      rc.bottom = newHeight;
      rc.top = oldHeight;
      FillRect (dc, &rc, brush);
    }
  DeleteObject (brush);
  SelectPalette (dc, oldPalette, TRUE);
  ReleaseDC (hwnd, dc);
#endif
}

void
tkobjc_raster_savePixmap (Raster *raster)
{
  raster_private_t *private = raster->private;

  private->oldpm = private->pm;
}

void
tkobjc_raster_copy (Raster *raster, unsigned oldWidth, unsigned oldHeight)
{
  raster_private_t *private = raster->private;
  unsigned minWidth = raster->width < oldWidth ? raster->width : oldWidth;
  unsigned minHeight = raster->height < oldHeight ? raster->height : oldHeight;

#ifndef _WIN32
  XCopyArea (Tk_Display (private->tkwin),
             private->oldpm, private->pm, private->gc,
             0, 0, minWidth, minHeight, 0, 0);
#else
  if (!dib_copy (private->oldpm, private->pm,
                 0, 0,
                 minWidth, minHeight))
    abort ();
#endif
}

void
tkobjc_raster_dropOldPixmap (Raster *raster)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  Display *display = Tk_Display (private->tkwin);

  XFreePixmap (display, private->oldpm);
#else
  dib_destroy (private->oldpm);
#endif
}

#ifndef _WIN32
static void
xpmerrcheck (int xpmerr, const char *what)
{
  const char *error = NULL;
  const char *warning = NULL;
  
  switch (xpmerr)
    {
    case XpmSuccess:
      break;
    case XpmColorError:
      warning = "Could not parse or alloc requested color";
      break;
    case XpmOpenFailed:
      error = "Cannot open file";
      break;
    case XpmFileInvalid:
      error = "Invalid XPM file";
      break;
    case XpmNoMemory:
      error = "Not enough memory";
      break;
    case XpmColorFailed:
      error = "Failed to parse or alloc some color";
      break;
    }
  if (warning)
    raiseEvent  (WarningMessage, "Creating pixmap: %s (%s)\n", warning, what);
  if (error)
    raiseEvent (PixmapError, "Creating pixmap: %s (%s)\n", error, what);
}
#endif

#ifndef _WIN32
static void
x_pixmap_create_from_window (Pixmap *pixmap, Window window)
{
  int x, y;
  unsigned w, h, bw, depth;
  XImage *ximage;
  Window root;
  
  if (!XGetGeometry (pixmap->display, window, &root,
                     &x, &y, &w, &h,
                     &bw, &depth))
    raiseEvent (PixmapError, "Cannot get geometry for root window");
  pixmap->height = h;
  pixmap->width = w;
  ximage = XGetImage (pixmap->display, window, 0, 0, w, h, AllPlanes, ZPixmap);
  if (ximage == NULL)
    raiseEvent (PixmapError, "Cannot get XImage of window");
  
  xpmerrcheck (XpmCreateXpmImageFromImage (pixmap->display, ximage, NULL,
                                           &pixmap->xpmimage, 
                                           NULL),
               "x_pixmap_create_from_window / XpmImage");
  
  xpmerrcheck (XpmCreatePixmapFromXpmImage (pixmap->display,
                                            window,
                                            &pixmap->xpmimage,
                                            &pixmap->pixmap,
                                            &pixmap->mask,
                                            NULL),
               "x_pixmap_create_from_window / Pixmap");
  XDestroyImage (ximage);
}
#else
static void
win32_pixmap_create_from_window (Pixmap *pixmap,
				 Window window,
				 BOOL decorationsFlag)
{
  dib_t *dib = dib_create ();
  dib->window = (!window
		 ? HWND_DESKTOP
		 : (!decorationsFlag
		    ? TkWinGetHWND (window)
		    : (HWND)window));
  
  pixmap->pixmap = dib;
  {
    RECT rect;

    GetWindowRect (dib->window, &rect);
    pixmap->height = rect.bottom - rect.top;
    pixmap->width = rect.right - rect.left;
  }
  dib_snapshot (dib, decorationsFlag);
}
#endif

static void
pixmap_create_from_root_window (Pixmap *pixmap)
{
#ifndef _WIN32
  Tk_Window tkwin = tkobjc_nameToWindow (".");
  Window root;
  
  pixmap->display = Tk_Display (tkwin);
  root = RootWindow (pixmap->display, DefaultScreen (pixmap->display));
  x_pixmap_create_from_window (pixmap, root);
#else
  win32_pixmap_create_from_window (pixmap, 0, NO);
#endif
}

static BOOL
keep_inside_screen (Tk_Window tkwin, Window window)
{
  int x, rx, y, ry;
  int nx, ny;
  unsigned w, rw, h, rh;
  unsigned dx, dy;

#ifndef _WIN32
  Display *display = Tk_Display (tkwin);
  Window root;
  unsigned bw, rbw, depth, rdepth;

  if (!XGetGeometry (display, window, &root,
                     &x, &y, &w, &h,
                     &bw, &depth))
    raiseEvent (PixmapError, "Cannot get geometry for window");

  if (!XGetGeometry (display, root, &root,
                     &rx, &ry, &rw, &rh,
                     &rbw, &rdepth))
    raiseEvent (PixmapError, "Cannot get geometry for root window");
  if (Tk_WindowId (tkwin) != window)
    {
      w += bw * 2;
      h += bw * 2;
    }
#else
  RECT rect, rootrect;
  // wm frame returns a hwnd
  HWND hwnd = ((Tk_WindowId (tkwin) == window) ?
	       TkWinGetHWND (window) 
	       : (HWND)window);
  
  if (GetWindowRect (hwnd, &rect) == FALSE)
    raiseEvent (PixmapError, "Cannot get geometry for window");
  h = rect.bottom - rect.top;
  w = rect.right - rect.left;
  x = rect.left;
  y = rect.top;

  if (GetWindowRect (HWND_DESKTOP, &rootrect) == FALSE)
    raiseEvent (PixmapError, "Cannot get geometry for desktop");

  rx = rootrect.left;
  ry = rootrect.top;
  rh = rootrect.bottom - rootrect.top;
  rw = rootrect.right - rootrect.left;
#endif

  if (Tk_WindowId (tkwin) == window)
    {
      x = Tk_X (tkwin);
      y = Tk_Y (tkwin);
      dx = 0;
      dy = 0;
    }
  else
    {
      dx = Tk_X (tkwin) - x;
      dy = Tk_Y (tkwin) - y;
    }
  if (x + w > rw)
    nx = rw - w;
  else if (x < 0)
    nx = 0;
  else
    nx = x;
  
  if (y + h > rh)
    ny = rh - h;
  else if (y < 0)
    ny = 0;
  else
    ny = y;

  if (nx != x || ny != y)
    {
      Tk_MoveToplevelWindow (tkwin, nx + dx, ny + dy);
      while (Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT));

      return YES;
    }
  return NO;
}

#ifndef _WIN32
static BOOL
overlap_p (Display *display, Window parent, Window child, int l, int r, int t, int b)
{
  int cl, cr, ct, cb;
  unsigned cw, ch;
  unsigned cbw, cdepth;
  int bl, br, bt, bb;
  Window root;
  XWindowAttributes attr;

  if (!XGetWindowAttributes (display, child, &attr))
    abort ();
  if (attr.map_state == IsViewable
      && attr.depth > 0
      && parent != child)
    {
      if (!XGetGeometry (display, child, &root,
                         &cl, &ct, &cw, &ch, 
                         &cbw, &cdepth))
        abort ();
      cr = cl + cw;
      cb = ct + ch;
      
      bl = (l > cl) ? l : cl;
      br = (r < cr) ? r : cr;
      
      bt = (t > ct) ? t : ct;
      bb = (b < cb) ? b : cb;
      
      return (bt <= bb && bl <= br);
    }
  return NO;
}

static void
check_for_overlaps (Display *display, Window parent,
                    Window **overlapWindowsPtr, unsigned *overlapCountPtr)
{
  Window root;
  Window *children;
  unsigned nchildren, i;
  int l, r, t, b;
  unsigned w, h;
  unsigned bw, depth;
  int rl, rt;
  unsigned rw, rh;
  unsigned rbw, rdepth;


  if (!XGetGeometry (display, parent, &root, &l, &t, &w, &h, &bw, &depth))
    abort ();
  r = l + w;
  b = t + h;

  if (!XGetGeometry (display, root, &root,
                     &rl, &rt, &rw, &rh, 
                     &rbw, &rdepth))
    abort ();
  if (!XQueryTree (display, root, &root, &root, &children, &nchildren))
    abort ();
  {  
    Window *overlapWindows;
    unsigned overlapCount = 0;
    
    for (i = 0; i < nchildren; i++)
      overlapCount += overlap_p (display, parent, children[i], l, r, t, b);
    overlapWindows = xmalloc (sizeof (Window) * overlapCount);
    overlapCount = 0;
    for (i = 0; i < nchildren; i++)
      if (overlap_p (display, parent, children[i], l, r, t, b))
        overlapWindows[overlapCount++] = children[i];
    *overlapCountPtr = overlapCount;
    *overlapWindowsPtr = overlapWindows;
  }
  XFree (children);
}
#endif

void
tkobjc_pixmap_create_from_widget (Pixmap *pixmap, id <Widget> widget,
                                  BOOL decorationsFlag)
{
  if (widget == nil)
    pixmap_create_from_root_window (pixmap);
  else
    {
      id topLevel = [widget getTopLevel];
      const char *widgetName = [topLevel getWidgetName];
      Tk_Window tkwin = tkobjc_nameToWindow (widgetName);
      Window window, topWindow;

      [globalTkInterp eval: "wm frame %s", widgetName];
      sscanf ([globalTkInterp result], "0x%x", (int *)&topWindow);

      window = decorationsFlag ? topWindow : Tk_WindowId (tkwin);

      [topLevel deiconify];
      while (Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT));
#ifndef _WIN32
      pixmap->display = Tk_Display (tkwin);
      {
        unsigned overlapCount, i;
        Window *overlapWindows;
        Display *display = pixmap->display;
        XSetWindowAttributes attr;
        XWindowAttributes top_attr;
        BOOL obscured = NO;
        
	keep_inside_screen (tkwin, window);
        check_for_overlaps (display, topWindow,
                            &overlapWindows, &overlapCount);

        [globalTkInterp eval: "uplevel #0 {\n"
                        "set obscured no\n"
                        "}\n"];
        
        [globalTkInterp eval: "bind %s <Expose> {\n"
                        "uplevel #0 {\n"
                        "set obscured yes\n"
                        "}\n}\n", widgetName, widgetName];

        [globalTkInterp eval: "bind %s <Visibility> {\n"
                        "uplevel #0 {\n"
                        "if {\"%%s\" != \"VisibilityUnobscured\"} {\n"
                        "set obscured yes\n"
                        "}\n}\n}\n", widgetName, widgetName];

        attr.override_redirect = True;
        XChangeWindowAttributes (display, topWindow,
                                 CWOverrideRedirect, &attr);
        for (i = 0; i < overlapCount; i++)
          XChangeWindowAttributes (display, overlapWindows[i],
                                   CWOverrideRedirect,
                                   &attr);

        if (!XGetWindowAttributes (display, topWindow, &top_attr))
          abort ();
        if (top_attr.map_state == IsUnmapped)
          XMapWindow (display, topWindow);
      retry:
        if (obscured)
          for (i = 0; i < overlapCount; i++)
            XUnmapWindow (display, overlapWindows[i]);
        
        Tk_RestackWindow (tkwin, Above, NULL);
        while (Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT));
        if (!obscured
            && strcmp ([globalTkInterp
                         globalVariableValue: "obscured"],
                       "yes") == 0)
          {
            obscured = YES;
            goto retry;
          }
        XFlush (display);
        x_pixmap_create_from_window (pixmap, window);
        
        if (top_attr.map_state == IsUnmapped)
          XUnmapWindow (display, topWindow);
        attr.override_redirect = False;
        XChangeWindowAttributes (display, topWindow,
                                 CWOverrideRedirect, &attr);
        for (i = 0; i < overlapCount; i++)
          {
            if (obscured)
              XMapWindow (display, overlapWindows[i]);
            XChangeWindowAttributes (display, overlapWindows[i],
                                     CWOverrideRedirect,
                                     &attr);
          }
        xfree (overlapWindows);
        [globalTkInterp eval: "bind %s <Visibility> {}\n", widgetName];
        [globalTkInterp eval: "bind %s <Expose> {}\n", widgetName];
      }
#else
      keep_inside_screen (tkwin, topWindow);
      SetWindowPos ((HWND)topWindow,
		    HWND_TOPMOST, 0, 0, 0, 0,
		    SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
      while (Tk_DoOneEvent(TK_ALL_EVENTS|TK_DONT_WAIT));
      GdiFlush ();
      win32_pixmap_create_from_window (pixmap, window, decorationsFlag);
#endif
    }
}

void
tkobjc_pixmap_update_raster (Pixmap *pixmap, Raster *raster)
{
#ifdef _WIN32
#if 0
  // (Apparently, there isn't a need to merge the pixmap and raster
  // pixmaps by hand, but without doing so, somehow the black
  // gets lost. -mgd)
  dib_t *raster_dib = private->pm;
  
  if (dib_paletteIndexForObject (raster_dib, pixmap) == -1)
    {
      unsigned palette_size = pixmap->palette_size;
      png_colorp palette = pixmap->palette;
      unsigned long map[palette_size];
      unsigned i;
      
      for (i = 0; i < palette_size; i++)
        map[i] = palette[i].red
          | (palette[i].green << 8)
          | (palette[i].blue << 16);
      
      dib_augmentPalette (raster_dib, pixmap, palette_size, map);
    }
#endif
#else
  {
    raster_private_t *private = raster->private;

    Tk_Window tkwin = private->tkwin;
    Display *display = Tk_Display (tkwin);
    Window window = Tk_WindowId (tkwin);
    Colormap *colormap = raster->colormap;
    BOOL retryFlag = NO;
    
    while (1)
      {
        XpmAttributes xpmattrs;
        int err;
        
        xpmattrs.valuemask = XpmColormap;
        xpmattrs.colormap = colormap->cmap;
        if ((err = XpmCreatePixmapFromXpmImage (display,
                                                window,
                                                &pixmap->xpmimage,
                                                &pixmap->pixmap,
                                                &pixmap->mask,
                                                &xpmattrs)) != XpmSuccess)
          {
            if (retryFlag == YES)
              {
                xpmerrcheck (err, __FUNCTION__);
                break;
              }
            raiseEvent (ResourceAvailability, 
                        "Switching to virtual colormap.\n");
            colormap->cmap = XCopyColormapAndFree (display, colormap->cmap);
            tkobjc_raster_setColormap (raster);
            retryFlag = YES;
          }
        else
          break;
      }
  }
#endif
}


void
tkobjc_pixmap_create (Pixmap *pixmap,
                      png_bytep *row_pointers,
                      unsigned bit_depth)
{
  unsigned palette_size = pixmap->palette_size;
  png_colorp palette = pixmap->palette;

#ifndef _WIN32
  XpmColor *colors = xmalloc (sizeof (XpmColor) * palette_size);
  
  pixmap->xpmimage.width = pixmap->width;
  pixmap->xpmimage.height = pixmap->height;
  pixmap->xpmimage.cpp = 7;
  {
    unsigned i;
    
    for (i = 0; i < palette_size; i++)
      {
        XpmColor *color = &colors[i];
        char *str = xmalloc (1 + 2 * 3 + 1);
        
        sprintf (str, "#%02x%02x%02x",
                 palette[i].red, palette[i].green, palette[i].blue);
        color->string = NULL;
        color->symbolic = str;
        color->m_color = NULL;
        color->g4_color = NULL;
        color->g_color = NULL;
        color->c_color = str;
      }
    pixmap->xpmimage.ncolors = palette_size;
    pixmap->xpmimage.colorTable = colors;
  }
  {
    unsigned *data = xmalloc (sizeof (int)
                              * pixmap->xpmimage.width
                              * pixmap->xpmimage.height);
    unsigned *out_pos = data;
    unsigned ri;
    unsigned drop_shift = (8 - bit_depth) & 7;
    
    for (ri = 0; ri < pixmap->xpmimage.height; ri++)
      {
        unsigned ci, width = pixmap->xpmimage.width;
        png_bytep in_row = row_pointers[ri];
        
        for (ci = 0; ci < width; ci++)
          {
            unsigned bit_pos = bit_depth * ci;
            unsigned byte_offset = bit_pos >> 3;
            unsigned bit_shift = bit_pos & 7;
            png_byte val = in_row[byte_offset];

            val <<= bit_shift;
            val >>= drop_shift;
            
            *out_pos++ = val;
          }
      }
    pixmap->xpmimage.data = data;
  }
#else
  {
    dib_t *dib = dib_create ();
    unsigned long map[palette_size];
    unsigned ci;

    dib_createBitmap (dib, NULL, pixmap->width, pixmap->height);
    
    for (ci = 0; ci < palette_size; ci++)
      map[ci] = palette[ci].red
	| (palette[ci].green << 8)
	| (palette[ci].blue << 16);
    
    dib_augmentPalette (dib, pixmap, palette_size, map);
    {
      LPBYTE out_pos = dib_lock (dib);
      WORD depth = dib->dibInfo->bmiHead.biBitCount;
      unsigned drop_shift = (8 - bit_depth) & 7;
      
      unsigned ri;
      
      for (ri = 0; ri < pixmap->height; ri++)
	{
	  unsigned ci;
	  png_bytep in_row = row_pointers[ri];
	  
	  for (ci = 0; ci < pixmap->width; ci++)
	    {
	      unsigned bit_pos = bit_depth * ci;
	      unsigned byte_offset = bit_pos >> 3;
	      unsigned bit_shift = bit_pos & 0x7;
	      BYTE val = in_row[byte_offset];

	      val <<= bit_shift;
	      val >>= drop_shift;

	      if (depth == 8)
		*out_pos++ = val;
	      else
		{
		  *out_pos++ = palette[val].blue;
		  *out_pos++ = palette[val].green;
		  *out_pos++ = palette[val].red;
		}
	    }
	}
      dib_unlock (dib);
    }
    pixmap->pixmap = dib;
  }
#endif
}

void
tkobjc_pixmap_draw (Pixmap *pixmap, int x, int y, Raster *raster)
{
  raster_private_t *private = raster->private;
#ifndef _WIN32
  Tk_Window tkwin = tkobjc_nameToWindow (".");
  Display *display = Tk_Display (tkwin);
  GC gc = private->gc;
  Drawable w = private->pm;
  X11Pixmap mask = pixmap->mask;
  
  if (mask == 0)
    XCopyArea (display, pixmap->pixmap, w, gc, 0, 0,
               pixmap->width, pixmap->height,
               x, y);
  else
    {
      XSetClipMask (display, gc, mask);
      XCopyArea (display, pixmap->pixmap, w, gc, 0, 0,
                 pixmap->width, pixmap->height,
                 x, y);
      XSetClipMask (display, gc, None);
    }
#else
  dib_copy (pixmap->pixmap, private->pm, x, y, pixmap->width, pixmap->height);
#endif
}

void
tkobjc_pixmap_save (Pixmap *pixmap, const char *filename)
{
  FILE *fp = fopen (filename, "wb");
  png_structp png_ptr;
  png_infop info_ptr;
  unsigned width = pixmap->width;
  unsigned height = pixmap->height;
#ifdef _WIN32
  dib_t *dib = pixmap->pixmap;
#endif
  
  if (fp == NULL)
    raiseEvent (PixmapError, "Cannot open output pixmap file: %s\n", filename);
  
  png_ptr = png_create_write_struct (PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (png_ptr == NULL)
    {
      fclose (fp);
      raiseEvent (PixmapError, "Could not create PNG write struct\n");
    }
  
  info_ptr = png_create_info_struct (png_ptr);
  if (info_ptr == NULL)
    {
      png_destroy_write_struct (&png_ptr, (png_infopp)NULL);
      fclose (fp);
      raiseEvent (PixmapError, "Could not create PNG info struct\n");
    }
  
  if (setjmp (png_ptr->jmpbuf))
    {
      png_destroy_write_struct (&png_ptr, &info_ptr);
      fclose (fp);
      raiseEvent (PixmapError, "Error during PNG write of %s\n", filename);
    }
  
  png_init_io (png_ptr, fp);
  {
#ifndef _WIN32
    unsigned *data = pixmap->xpmimage.data;
    XpmColor *colorTable = pixmap->xpmimage.colorTable;
#else
    LPBYTE data = dib->bits;
    RGBQUAD *rgb = dib->dibInfo->rgb;
#endif
    unsigned ci;
    // row_pointers will point to these
    png_byte rgbbuf[height][width][3];
    png_byte palbuf[height][width]; 

    png_bytep row_pointers[height];
#ifndef _WIN32
    int ncolors = pixmap->xpmimage.ncolors;
#else
    int ncolors = ((dib->dibInfo->bmiHead.biBitCount == 24
		    && dib->colormap == NULL)
		   ? -1
		   : dib->colormapSize);
#endif
    
    if (ncolors != -1)
      {
	png_color palette[ncolors];

	for (ci = 0; ci < (unsigned)ncolors; ci++)
	  {
#ifndef _WIN32
	    unsigned red, green, blue;
	    
	    sscanf (colorTable[ci].c_color, "#%4x%4x%4x", 
		    &red, &green, &blue);
	    palette[ci].red = red >> 8;
	    palette[ci].green = green >> 8;
	    palette[ci].blue = blue >> 8;
#else
	    palette[ci].red = rgb[ci].rgbRed;
	    palette[ci].green = rgb[ci].rgbGreen;
	    palette[ci].blue = rgb[ci].rgbBlue;
#endif
	  }
	if (ncolors < 256)
	  {
	    unsigned xi, yi;
#ifndef _WIN32
	    unsigned *data = pixmap->xpmimage.data;
#else
	    LPBYTE data = dib->bits;
#endif	    
	    for (yi = 0; yi < height; yi++)
	      for (xi = 0; xi < width; xi++)
		palbuf[yi][xi] = (png_byte)*data++;
	    
	    for (yi = 0; yi < height; yi++)
	      row_pointers[yi] = &palbuf[yi][0];

	    png_set_IHDR (png_ptr, info_ptr,
			  width, height,
			  8, PNG_COLOR_TYPE_PALETTE,
			  PNG_INTERLACE_NONE,
			  PNG_COMPRESSION_TYPE_DEFAULT,
			  PNG_FILTER_TYPE_DEFAULT);
	    png_set_PLTE (png_ptr, info_ptr, palette, ncolors);
	    png_write_info (png_ptr, info_ptr);
	  }
	else
	  {
	    unsigned yi, xi;
	    
	    for (yi = 0; yi < height; yi++)
	      for (xi = 0; xi < width; xi++)
		{
		  png_color color = palette[*data++];
		  rgbbuf[yi][xi][0] = color.red;
		  rgbbuf[yi][xi][1] = color.green;
		  rgbbuf[yi][xi][2] = color.blue;
		}
	    for (yi = 0; yi < height; yi++)
	      row_pointers[yi] = &rgbbuf[yi][0][0];
	  }
      }
    else
#ifndef _WIN32
        abort ();
#else
      {
	unsigned yi;
	    
	for (yi = 0; yi < height; yi++)
	  {
	    BYTE (*ybasesource)[1][3] = (void *) &data[width * yi * 3];
	    png_byte (*ybasedest)[1][3] = &rgbbuf[yi];
	    unsigned xi;

	    for (xi = 0; xi < width; xi++)
	      {
		LPBYTE source = (LPBYTE) &ybasesource[xi][0];
		png_bytep dest = (png_bytep) &ybasedest[xi][0];

		dest[0] = source[2];
		dest[1] = source[1];
		dest[2] = source[0];
	      }
	    row_pointers[yi] = (png_bytep)ybasedest;
	  }
      }
#endif
    
    if (ncolors == -1 || ncolors > 256)
      {
	png_set_IHDR (png_ptr, info_ptr,
		      width, height,
		      8, PNG_COLOR_TYPE_RGB,
		      PNG_INTERLACE_NONE,
		      PNG_COMPRESSION_TYPE_DEFAULT,
		      PNG_FILTER_TYPE_DEFAULT);
	
	png_set_sRGB (png_ptr, info_ptr, PNG_sRGB_INTENT_PERCEPTUAL);
	png_write_info (png_ptr, info_ptr);
      }
    
    png_write_image (png_ptr, row_pointers);
  }
  png_write_end (png_ptr, info_ptr);
  png_destroy_write_struct (&png_ptr, &info_ptr);
  fclose (fp);
}


void
tkobjc_pixmap_drop (Pixmap *pixmap)
{
#ifndef _WIN32
  XFreePixmap (pixmap->display, pixmap->pixmap);
  if (pixmap->mask)
    XFreePixmap (pixmap->display, pixmap->mask);
  XpmFreeXpmImage (&pixmap->xpmimage);
#else
  dib_destroy (pixmap->pixmap);
#endif
}