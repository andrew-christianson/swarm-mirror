// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         Action.h
Description:  action included in an activity plan
Library:      activity
*/

#import <defobj.h>
#import <defobj/Create.h>
#import <activity/CompoundAction.h>
#import <activity.h>

#include <swarmconfig.h>

@interface CAction: CreateDrop_s
{
@public
  ActionType_c *owner;       // action type that binds action in its context
  member_t ownerActions;     // internal links in actions owned by ActionType
  unsigned bits;             // bit allocations
  BOOL autoDropFlag;
}
- getOwner;
@end

@interface PAction: CAction
{
@public
  id <FCall> call;
  id target; 
}
@end

@interface PFAction: PAction <Action, ActionArgs>
{
  unsigned argCount;
  id arg1, arg2, arg3;
}
+ createBegin: aZone;
- (void)_addArguments_: (id <FArguments>)arguments;
- (unsigned)getNArgs;
- (void)setArg1: arg1;
- (void)setArg2: arg2;
- (void)setArg3: arg3;
- getArg1;
- getArg2;
- getArg3;
- (void)mapAllocations: (mapalloc_t)mapalloc;
- (void)_performAction_: (id <Activity>)activity;
@end

@interface FAction_c: PAction <Action>
{
}
- createEnd;
- setCall: fcall;
- setAutoDrop: (BOOL)autoDrop;
- (void)_performAction_: (id <Activity>)anActivity;
- (void)describe: outputCharStream;
@end

@interface ActionCall_c: PFAction
{
  func_t funcPtr;
}
- (void)setFunctionPointer: (func_t)funcPtr;
- createEnd;
- (func_t)getFunctionPointer;
- (void)describe: outputCharStream;
@end

@interface ActionTo_c: PFAction <ActionArgs>
{
@public
  SEL selector;
  id protoTarget;
}
- createEnd;
- _createCall_: protoTarget;
- (void)_performAction_: (id <Activity>)activity;
- (void)setTarget: aTarget;
- getTarget;
- (void)setMessageSelector: (SEL)aSel;
- (SEL)getMessageSelector;
- (void)describe: outputCharStream;
@end

@interface ActionForEach_c: ActionTo_c <ActionForEach>
{
}
- setDefaultOrder: (id <Symbol>)aSymbol;
- (void)describe: outputCharStream;
- (void)_performAction_: (id <Activity>)activity;
@end

@interface FActionForEachHeterogeneous_c: FAction_c <FActionForEachHeterogeneous>
{
}
- setTarget: target;
- setDefaultOrder: (id <Symbol>)aSymbol;
- (void)_performAction_: (id <Activity>)anActivity;
- (id <Symbol>)getDefaultOrder;
- (void)describe: stream;
@end

@interface FActionForEachHomogeneous_c: FAction_c <FActionForEachHomogeneous>
{
  size_t targetCount;
#ifdef HAVE_JDK
  JOBJECT *javaTargets;
#endif
  id *objcTargets;
}
- setTarget: target;
- createEnd;
- setDefaultOrder: (id <Symbol>)aSymbol;
- (void)_performAction_: (id <Activity>)anActivity;
- (id <Symbol>)getDefaultOrder;
- (void)describe: stream;
@end
