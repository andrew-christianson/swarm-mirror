// Copyright (C) 1995-1998 The Santa Fe Institute.
// No warranty implied, see LICENSE for terms.

#import <objectbase.h>
#import <gui.h>

@interface DiGraph: SwarmObject
{
  id nodeList;
  id <Canvas> canvas;

  // For BoingDistribute...
  float springLength;
}

- setCanvas: aCanvas;
- createEnd;
- showCanvas: aCanvas;
- hideCanvas;
- getCanvas;
- getNodeList;
- addNode: aNode;
- dropNode: which;
- addLinkFrom: this To: that;
- removeLink: aLink;
- update;

// Node placement techniques...

- redistribute;

- setSpringLength: (float) aLength;
- boingDistribute: (int) iterations;
- boingDistribute;
- (double) boingStep;

@end
