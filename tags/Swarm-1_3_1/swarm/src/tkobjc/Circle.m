// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <tkobjc/Circle.h>
#import <tkobjc/Widget.h>
#import <tkobjc/global.h>
#include <misc.h> // strdup

@implementation Circle

PHASE(Creating)

- setX: (int)the_x Y: (int)the_y
{
  x = the_x;
  y = the_y;

  return self;
}
 
- setRadius: (unsigned)the_radius
{
  r = the_radius;

  return self;
}

- createItem
{
  [globalTkInterp eval: 
    "%s create oval %d %d %d %d -fill white", 
    [canvas getWidgetName],x - r, y - r, x + r, y + r];
  
  item = strdup ([globalTkInterp result]);

  return self;
}

@end
