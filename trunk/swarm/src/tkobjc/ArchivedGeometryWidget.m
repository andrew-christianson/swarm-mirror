// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#include "internal.h"
#import <tkobjc/ArchivedGeometryWidget.h>
#import <tkobjc/WindowGeometryRecord.h>
#import <tkobjc/global.h>
#import <defobj.h> // Archiver methods

@implementation ArchivedGeometryWidget

PHASE(Creating)

+ createBegin: aZone
{
  ArchivedGeometryWidget *obj = [super createBegin: aZone];

  obj->windowGeometryRecordName = NULL;
  obj->destroyedFlag = NO;
  return obj;
}

- setWindowGeometryRecordName: (const char *)name
{
  windowGeometryRecordName = name ? STRDUP (name) : NULL;
  return self;
}

- setSaveSizeFlag: (BOOL)theSaveSizeFlag
{
  saveSizeFlag = theSaveSizeFlag;

  return self;
}

- loadWindowGeometryRecord
{
  id windowGeometryRecord = nil;

  if (windowGeometryRecordName)
    windowGeometryRecord = [lispArchiver getObject: windowGeometryRecordName];
  return windowGeometryRecord;
}

- registerAndLoad
{
  id windowGeometryRecord;

  [lispArchiver registerClient: self];
  windowGeometryRecord = [self loadWindowGeometryRecord];
  tkobjc_setName (self, windowGeometryRecordName);
  if (windowGeometryRecord)
    {
      id topLevel = [self getTopLevel];

      if ([windowGeometryRecord getSizeFlag])
        [topLevel setWidth: [windowGeometryRecord getWidth]
                  Height: [windowGeometryRecord getHeight]];
      if ([windowGeometryRecord getPositionFlag])
        [topLevel setX: [windowGeometryRecord getX]
                  Y: [windowGeometryRecord getY]];
    }

  return self;
}

- createEnd
{
  [super createEnd];
  [self registerAndLoad];

  return self;
}

PHASE(Using)

- updateArchiver: archiver
{
  if (windowGeometryRecordName)
    {
      id windowGeometryRecord =
        [archiver getObject: windowGeometryRecordName];
      
      if (windowGeometryRecord == nil)
        windowGeometryRecord = [WindowGeometryRecord create: [self getZone]];

      if (saveSizeFlag)
        [windowGeometryRecord setWidth: [self getWidth]
                              Height: [self getHeight]];
      [windowGeometryRecord setX: [self getX] Y: [self getY]];
      [archiver putShallow: windowGeometryRecordName
                    object: windowGeometryRecord];
    }
  return self;
}

- (void)drop
{ 
  if (windowGeometryRecordName)
    FREEBLOCK (windowGeometryRecordName);

  [lispArchiver unregisterClient: self];

  [super drop];
}
@end
