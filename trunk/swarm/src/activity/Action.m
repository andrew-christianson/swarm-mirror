// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         Action.m
Description:  atomic action included to be included in an activity 
Library:      activity
*/

#import <activity/Action.h>
#import <activity/ActionGroup.h>
#import <activity/Schedule.h>

#include <swarmconfig.h>
#ifdef HAVE_JDK
#import "java.h" // SD_JAVA_FIND_OBJECT_JAVA
#import <defobj/FCall.h>
#endif
#import <defobj/defalloc.h> // getZone

extern id uniformUnsRand;
@protocol _MinimalRandom
- (unsigned)getUnsignedWithMin: (unsigned)minVal withMax: (unsigned)maxVal;
@end

@implementation CAction
PHASE(Creating)
- createEnd
{
  [super createEnd];
  autoDropFlag = YES;
  setMappedAlloc (self);
  return self;
}

PHASE(Using)
- getOwner
{
  return owner;
}

- (void)mapAllocations: (mapalloc_t)mapalloc
{
}
@end

@implementation PAction
PHASE(Creating)
PHASE(Using)
@end

@implementation PFAction
PHASE(Creating)
+ createBegin: aZone
{
  PFAction *action = [super createBegin: aZone];

  action->argCount = 0;
  return action;
}

- (void)setArg1: anArg
{
  arg1 = anArg;
  if (argCount < 1)
    argCount = 1;
}

- (void)setArg2: anArg
{
  arg2 = anArg;
  if (argCount < 2)
    argCount = 2;
}

- (void)setArg3: anArg
{
  arg3 = anArg;
  if (argCount < 3)
    argCount = 3;
}

PHASE(Using)
- (void)_addArguments_: (id <FArguments>)arguments
{
  if (argCount >= 1)
    [arguments addObject: arg1];
  if (argCount >= 2)
    [arguments addObject: arg2];
  if (argCount >= 3)
    [arguments addObject: arg3];
}

- (void)_performAction_: (id <Activity>)anActivity
{
  [call performCall];
}

- (void)describe: outputCharStream
{
  [outputCharStream catC: "PFAction"];
}

- (unsigned)getNArgs
{
  return argCount;
}

- getArg1
{
  return arg1;
}

- getArg2
{
  return arg2;
}

- getArg3
{
  return arg3;
}

- (void)mapAllocations: (mapalloc_t)mapalloc
{
  if (call && autoDropFlag)
    {
      mapObject (mapalloc, [call getArguments]);
      mapObject (mapalloc, call);
    }
}

@end

@implementation FAction_c
PHASE(Creating)
- createEnd
{
  [super createEnd];
  
  autoDropFlag = NO;
  return self;
}

- setCall: fcall
{
  call = fcall;
  return self;
}

PHASE(Setting)
- setAutoDrop: (BOOL)theAutoDropFlag
{
  autoDropFlag = theAutoDropFlag;
  return self;
}

PHASE(Using)
- (void)_performAction_: (id <Activity>)anActivity
{
  if (target) // in the case of FActionForEach
    updateTarget (call, target);
  
  [call performCall];
}

- (void)describe: outputCharStream
{
  [outputCharStream catC: "FAction\n"];
}
@end

@implementation ActionCall_c
PHASE(Creating)
- (void)setFunctionPointer: (func_t)theFuncPtr
{
  funcPtr = theFuncPtr;
}

- createEnd
{
  id <FArguments> arguments;

  [super createEnd];

  arguments = [FArguments createBegin: getCZone (getZone (self))];

  [arguments setObjCReturnType: _C_VOID];
  [self _addArguments_: arguments];
  arguments = [arguments createEnd];

  call = [FCall createBegin: getCZone (getZone (self))];
  [call setFunctionPointer: funcPtr];
  [call setArguments: arguments];
  call = [call createEnd];
  return self;
}

PHASE(Using)
- (func_t)getFunctionPointer
{
  return funcPtr;
}

static void
describeFunctionCall (id stream, func_t fptr, int nargs, id arg1, id arg2, id arg3)
{
  char buffer[100];

  sprintf (buffer, "(function at " PTRHEXFMT ")(", fptr);
  [stream catC: buffer];
  if (nargs > 0)
    {
      sprintf( buffer, PTRHEXFMT, arg1 );
      [stream catC: buffer];
      if (nargs > 1)
        {
          sprintf (buffer, ", " PTRHEXFMT, arg2);
          [stream catC: buffer];
          if (nargs > 2)
            {
              sprintf (buffer, ", " PTRHEXFMT, arg3);
              [stream catC: buffer];
            }
        }
    }
  [stream catC: ")\n"];
}

- (void)describe: outputCharStream
{
  describeFunctionCall (outputCharStream,
                        [call getFunctionPointer],
                        argCount, arg1, arg2, arg3);
}
@end

@implementation ActionTo_c
PHASE(Creating)
- (void)setTarget: aTarget
{
  protoTarget = target = aTarget;
}

- (void)setMessageSelector: (SEL)aSel
{
  selector = aSel;
}

- createEnd
{
  [super createEnd];

  if (protoTarget)
    call = [self _createCall_: protoTarget];
  else
    call = nil;
  return self;
}

PHASE(Using)
- _createCall_: theTarget
{
  id <FArguments> arguments =
    [FArguments createBegin: getCZone (getZone (self))];
  
  [arguments setJavaFlag: [theTarget respondsTo: M(isJavaProxy)]];
  [arguments setSelector: selector];
  [self _addArguments_: arguments];
  arguments = [arguments createEnd];

  return [FCall create: getCZone (getZone (self))
                target: theTarget
                selector: selector
                arguments: arguments];
}

- (void)_performAction_: (id <Activity>)anActivity
{
  if (call)
    {
      updateTarget (call, target);
      [call performCall];
    }
  else
    {
      id fc = [self _createCall_: target];

      [fc performCall];
      [[fc getArguments] dropAllocations: YES];
      [fc dropAllocations: YES];
    }
}

- getTarget
{
  return target;
}

- (SEL)getMessageSelector
{
  return selector;
}

static void
describeMessageArgs(id stream, SEL msg, int nargs, id arg1, id arg2, id arg3)
{
  char buffer[100];

  sprintf (buffer, " %s", sel_get_name (msg));
  [stream catC: buffer];
  if (nargs > 0)
    {
      sprintf (buffer, " " PTRHEXFMT, arg1);
      [stream catC: buffer];
      if (nargs > 1)
        {
          sprintf (buffer, " " PTRHEXFMT, arg2);
          [stream catC: buffer];
          if (nargs > 2)
            {
              sprintf (buffer, " " PTRHEXFMT, arg3);
              [stream catC: buffer];
            }
        }
    }
  [stream catC: "]\n"];
}

- (void)describe: stream
{
  char buffer[100];

  [stream catC: "["];
  _obj_formatIDString (buffer, target);
  [stream catC: buffer];
  describeMessageArgs (stream, selector, argCount, arg1, arg2, arg3);
}

@end

@implementation ActionForEach_c
PHASE(Creating)
- createEnd
{
  protoTarget = nil;
  return [super createEnd];
}

PHASE(Setting)
- setDefaultOrder: (id <Symbol>)aSymbol
{
  setDefaultOrder (&bits, aSymbol);
  return self;
}

PHASE(Using)
- (void)_performAction_: (id <Activity>)anActivity
{
  id memberAction;
  
  if (getBit (bits, BitRandomized))
    memberAction = 
      [id_ForEachActivity_c _createRandom_: self : anActivity ];
  else
    memberAction = [id_ForEachActivity_c _create_: self : anActivity ];
  
  setClass (memberAction, id_ActionTo_c);
}

- (id <Symbol>)getDefaultOrder
{
  return getDefaultOrder (bits);
}

- (void)describe: stream
{
  char buffer[100];

  [stream catC: "[[foreach: "];
  _obj_formatIDString (buffer, target);
  [stream catC: buffer];
  [stream catC: "]"];
  describeMessageArgs (stream, selector, argCount, arg1, arg2, arg3);

}

@end

@implementation ActionForEachHomogeneous_c
#define ACTION_HOMOGENEOUS_TYPE ActionForEachHomogeneous_c
#define SETUPCALL imp = objc_msg_lookup ([target getFirst], selector)
#define UPDATEOBJCTARGET(target)
#define PERFORMOBJCCALL(target) imp (target, selector)
#undef UPDATEJAVATARGET
#undef PERFORMJAVACALL
#include "ActionHomogeneous.m"
#undef PERFORMOBJCCALL
#undef UPDATEOBJCTARGET
#undef SETUPCALL
#undef ACTION_HOMOGENEOUS_TYPE
@end

@implementation FActionForEachHeterogeneous_c
PHASE(Creating)
- (void)setTarget: theTarget
{
  target = theTarget;
}

PHASE(Setting)
- setDefaultOrder: (id <Symbol>)aSymbol
{
  setDefaultOrder (&bits, aSymbol);
  return self;
}

PHASE(Using)

- (void)_performAction_: (id <Activity>)anActivity
{
  id memberAction;
  
  if (getBit (bits, BitRandomized))
    memberAction = 
          [id_ForEachActivity_c _createRandom_: self : anActivity];
  else
    memberAction = [id_ForEachActivity_c _create_: self : anActivity];
  
  setClass (memberAction, id_FAction_c);
}

- getTarget
{
  return target;
}

- (id <Symbol>)getDefaultOrder
{
  return getDefaultOrder (bits);
}

- (void)describe: stream
{
  char buffer[100];

  [stream catC: "[[faction foreach: "];
  _obj_formatIDString (buffer, target);
  [stream catC: buffer];
  [stream catC: "]"];
}

@end

@implementation FActionForEachHomogeneous_c
#define ACTION_HOMOGENEOUS_TYPE FActionForEachHomogeneous_c
#undef SETUPCALL
#define UPDATEOBJCTARGET(target) updateTarget (call, target)
#define PERFORMOBJCCALL(target) [call performCall]
#ifdef HAVE_JDK
#define UPDATEJAVATARGET(jtarget) updateJavaTarget (call, jtarget)
#define PERFORMJAVACALL(target) [call performCall]
#endif
#include "ActionHomogeneous.m"
#undef UPDATEJAVACALL
#undef UPDATECALL
#undef ACTION_HOMOGENEOUS_TYPE
@end
