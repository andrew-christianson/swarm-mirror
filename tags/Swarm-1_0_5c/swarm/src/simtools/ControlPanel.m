// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <activity.h>
#import <simtools.h>
#import <simtools/ControlPanel.h>
#import <simtools/Archiver.h>
#import <simtools/global.h>
#import <tkobjc/control.h>

// Rudimentary control panel. A lot of the work for making this useful
// falls on the shoulders of the controller that's using us, typically
// an observer swarm.

id ControlStateRunning, ControlStateStopped;
id ControlStateStepping, ControlStateNextTime, ControlStateQuit;

@implementation ControlPanel

- _actionCacheWarning_: (const char *)msg
{
  id string = [String create: [self getZone] setC: msg];
  
  [string 
    catC: 
      "Please change your application to call ActionCache instead.\n"];
  [ObsoleteMessage raiseEvent: [string getC]];
  [string drop];
  return self;
}

- createEnd
{
  [super createEnd];
  
  // default state is Stopped.
  state = ControlStateStopped;
  
  return self;
}

- getPanel
{
  [self _actionCacheWarning_: 
          "getPanel in ControlPanel is now does NOTHING!\n"];
  return self;
}

- getState
{
  return state;
}

- setState: theState
{
  state = theState;
  return self;
}

// What does a "waitForControlEvent" mean to a generic Swarm?  It's
// obvious what it means to a guiSwarm, and since we only instantiate
// a controlpanel with guiswarms, currently, we should provide some
// kind of passthrough from the gui to here.  I'm going to make this
// method block until the ControlPanel state changes.... via a call
// on a controlpanel method from some other object.  So, if the 
// gui isn't on it's own thread, nothing will happen here because 
// on a serial process, this busy wait loop LOCKS everything up.
//   Note also that this is how we do all the probe manipulations
// for the set up of runs.  The probe actions won't get done unless
// some polling action occurs here.  I.e. we don't want the schedule
// to move forward without doing the probe actions first.
// So, for the Tk version we still need a Tk poller; but in the Java
// version we don't as long as we have some mechanism other than the
// schedule for changing ObjC object state in response to Java
// events. 
- waitForControlEvent
{
  [self setState: ControlStateStopped];
  while (state == ControlStateStopped)
    tkobjc_doOneEventSync ();
  return nil;
}

- doTkEvents
{
  [self _actionCacheWarning_:
          "doTkEvents in ControlPanel now does NOTHING!\n"
        "You risk application lockups if you call ControlPanel doTkEvents.\n"];
  return self;
}

// Run: just set our own state to running, let whatever object who
// is using us arrange for the run to go again.
- startInActivity: activityID
{
  id controlState, activityState;
  
  while (YES)
    {
      controlState = [self getState];
      activityState = [activityID getStatus];
      
      if ((controlState == ControlStateRunning) && 
          (activityState != Running))
        activityState = [activityID run];
      else if (controlState == ControlStateStopped)
        [self setStateStopped];
      else if (controlState == ControlStateQuit)
        return Completed;  // this returns to go,which returns to main
      else if (controlState == ControlStateStepping) 
        {
          [activityID step];
          [self setStateStopped];
        }
      else if (controlState == ControlStateNextTime)
        {
          [activityID stepUntil: [activityID getCurrentTime]+1 ];
          [self setStateStopped];
        }
      else [self setStateStopped];
    }
  return [activityID getStatus];
}

// Stop: set state to stop, also stop activities.
- setStateStopped
{
  //  if (getTopLevelActivity()){
  [probeDisplayManager setDropImmediatelyFlag: YES];
  if (_activity_current)
    {
      [getTopLevelActivity() stop];
      return [self setState: ControlStateStopped];
    }
  else
    {
      [self setState: ControlStateStopped];
      [self waitForControlEvent];
      // Check now if the user hit the quit button: if so, abort.
      if ([self getState] == ControlStateQuit)
        exit(0);
      else
        return self;
    }
}

- setStateSave
{
  archiverSave ();
  return self;
}

- setStateRunning 
{
  [probeDisplayManager setDropImmediatelyFlag: NO];
  return [self setState: ControlStateRunning];
}

// Step: first, stop the running activity (we're probably already stopped,
// though). Then set our own state to Stepping.
 -setStateStepping
{
  [probeDisplayManager setDropImmediatelyFlag: YES];
  if (_activity_current)
  //  if (getTopLevelActivity())
    [getTopLevelActivity() stop];
  return [self setState: ControlStateStepping];
}

// Next time: first, stop the running activity (we're probably already stopped,
// though). Then set our own state to NextTime.
- setStateNextTime
{
  if (_activity_current)
    //  if (getTopLevelActivity())
    [getTopLevelActivity() stop];
  return [self setState: ControlStateNextTime];
}

// Quit: set state to quit, also terminate activities.
- setStateQuit
{
  //  if (getTopLevelActivity())
  if (_activity_current)
    [getTopLevelActivity() terminate];
  return [self setState: ControlStateQuit];
}

@end