// Swarm library. Copyright (C) 1996 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

// Objective C interface to BltGraph, for use with libtclobjc

#import <objc/Object.h>
#import <tkobjc/Widget.h>

@interface Histo : Widget {
  char ** elements;
  int numPoints;				  // should be dynamic
}

-setNumPoints: (int) n Labels: (char **) l Colors: (char **) c;  // how many points to draw.
-drawHistoWithDouble: (double *) points;	  // data format hack
-drawHistoWithInt: (int *) points;

// This is used by EZBin to avoid the usual integer tagging of elements...
-drawHistoWithInt: (int *) points atLocations: (double *) locations ;
-drawHistoWithDouble: (double *) points atLocations: (double *) locations ;

-title: (char *) t;                               // title the graph
-axisLabelsX: (char *) xl Y: (char *) yl;	  // change labels here.
@end