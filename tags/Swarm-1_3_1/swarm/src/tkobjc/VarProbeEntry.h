// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <tkobjc/Entry.h>
#import <gui.h>

@interface VarProbeEntry: Entry <_VarProbeEntry>
{
  id owner;
  id <VarProbe> varProbe;
  BOOL interactiveFlag;
}

- setInteractiveFlag: (BOOL)interactiveFlag;
- setOwner: owner;
- setVarProbe: varProbe;
- createEnd;
- getVarProbe;

@end