// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

// Objective C interface to Raster, for use with tclobjc.

#import <tkobjc/ArchivedGeometryWidget.h>
#ifndef _WIN32
#import <tkobjc/XDrawer.h>
#endif
#import <gui.h>
#import "internal.h"

// This could include a list of environments (graphics contexts).
@interface Raster: ArchivedGeometryWidget
{
  id button1Client, button2Client, button3Client;
  SEL button1Sel, button2Sel, button3Sel;
  PixelValue *map;
@public
  id <Colormap> colormap;
  Tk_Window tkwin;
  GC gc;
  Pixmap pm;
  unsigned width, height;
}

- (id <Colormap>)getColormap;
- setColormap: (id <Colormap>)colormap;
- drawPointX: (int)x Y: (int)y Color: (Color)c;
- fillRectangleX0: (int)x0 Y0: (int)y0 X1: (int)x1 Y1: (int)y1 Color: (Color)c;
#ifndef _WIN32
- draw: (id <XDrawer>)xd X: (int)x Y: (int)y;
#endif
- drawSelf;
- erase;
- handleButton: (int)n X: (int)x Y: (int)y;
- setButton: (int)n Client: c Message: (SEL)s;
@end