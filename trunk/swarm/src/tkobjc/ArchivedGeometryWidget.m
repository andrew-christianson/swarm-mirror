// Swarm library. Copyright (C) 1996-1998 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import "internal.h"
#import <tkobjc/ArchivedGeometryWidget.h>
#import <tkobjc/WindowGeometryRecord.h>
#import <tkobjc/global.h>

void archiverUnregister (id client);
void archiverRegister (id client);
void archiverPut (const char *key, id object);
id archiverGet (const char *key);

@implementation ArchivedGeometryWidget

- setWindowGeometryRecordName : (const char *)name
{
  windowGeometryRecordName = name;
  return self;
}

- loadWindowGeometryRecord
{
  id windowGeometryRecord = nil;

  if (windowGeometryRecordName)
    windowGeometryRecord = archiverGet (windowGeometryRecordName);
  return windowGeometryRecord;
}

+ createBegin: aZone
{
  ArchivedGeometryWidget *obj = [super createBegin: aZone];

  obj->windowGeometryRecordName = NULL;
  obj->destroyedFlag = NO;
  return obj;
}

- registerAndLoad
{
  id windowGeometryRecord;

  archiverRegister (self);
  windowGeometryRecord = [self loadWindowGeometryRecord];
  if (windowGeometryRecord)
    [self setWindowGeometry: [windowGeometryRecord getWindowGeometry]];
  return self;
}

- createEnd
{
  [super createEnd];
  [self registerAndLoad];
  return self;
}

- updateArchiver
{
  if (windowGeometryRecordName)
    {
      id windowGeometryRecord = archiverGet (windowGeometryRecordName);
      
      if (windowGeometryRecord == nil)
        windowGeometryRecord = [WindowGeometryRecord create: [self getZone]];
      
      [windowGeometryRecord setWindowGeometry: [self getWindowGeometry]];
      archiverPut (windowGeometryRecordName, windowGeometryRecord);
    }
  return self;
}

- (void)drop
{ 
  [self disableDestroyNotification];
  archiverUnregister (self);

  if (!destroyedFlag)
    [globalTkInterp eval: "destroy %s", [parent getWidgetName]]; 
  [super drop];
}

- (BOOL)getDestroyedFlag
{
  return destroyedFlag;
}

- _notifyTarget_
{
  destroyedFlag = YES;
  [destroyNotificationTarget perform: destroyNotificationMethod with: self];
  return self;
}

static void
structure_proc (ClientData clientdata, XEvent *eventptr)
{
  if (eventptr->type == DestroyNotify)
    [(id)clientdata _notifyTarget_];
}

- enableDestroyNotification: theNotificationTarget
         notificationMethod: (SEL)theNotificationMethod
{
  if (theNotificationTarget)
    {
      tkobjc_createEventHandler (self, structure_proc);
      
      destroyNotificationTarget = theNotificationTarget;
      destroyNotificationMethod = theNotificationMethod;
    }
  return self;
}

- disableDestroyNotification
{
  if (destroyNotificationTarget != nil)
    {
      tkobjc_deleteEventHandler (self, structure_proc);
      destroyNotificationTarget = nil;
    }
  return self;
}

@end
