// Swarm library. Copyright � 1996-1999 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <defobj/Archiver.h>

#import <collections.h>
#import <defobj.h> // STRDUP
#import <defobj/defalloc.h> // getZone
#include <misc.h> // getenv, stpcpy

const char *
defaultPath (const char *swarmArchiver)
{
  const char *home = getenv ("HOME");

  if (home)
    {
      size_t homelen = strlen (home);
      char *buf =
        [scratchZone alloc: homelen + 1 + strlen (swarmArchiver) + 1];
      char *p = stpcpy (buf, home);

      if (homelen == 0 || home[homelen - 1] != '/')
        p = stpcpy (p, "/");

      p = stpcpy (p, swarmArchiver);
      
      return buf;
    }
  return NULL;
}

const char *
defaultAppPath (const char *appDataPath, const char *appName,
                const char *suffix)
{
  char *buf =
    [scratchZone
      alloc: 
        strlen (appDataPath) + strlen (appName) + strlen (suffix) + 1];
  char *p;
  
  p = stpcpy (buf, appDataPath);
  p = stpcpy (p, appName);
  p = stpcpy (p, suffix);
  return buf;
}

@implementation ArchiverObject
+ create: aZone withExpr: valexpr
{
  id obj = [self createBegin: aZone];
  [obj setExpr: valexpr];
  [obj setObject: nil];
  return [obj createEnd];
}

+ create: aZone withObject: theObj
{
  id obj = [self createBegin: aZone];
  [obj setExpr: nil];
  [obj setObject: theObj];
  return [obj createEnd];
}

- setExpr: valexpr
{
  expr = valexpr;
  return self;
}
- getExpr
{
  return expr;
}

- setObject: obj
{
  object = obj;
  return self;
}

- getObject
{
  return object;
}
@end

@implementation Application
+ createBegin: aZone
{
  Application *obj = [super createBegin: aZone];

  obj->deepMap = [Map create: aZone];
  obj->shallowMap = [Map create: aZone];
  obj->name = "EMPTY";

  return obj;
}

- setName: (const char *)theName
{
  name = STRDUP (theName);
  return self;
}

- getDeepMap
{
  return deepMap;
}

- getShallowMap
{
  return shallowMap;
}

- (void)drop
{
  [shallowMap drop];
  [deepMap drop];
  [super drop];
}

@end

@implementation Archiver_c
PHASE(Creating)

+ createBegin: aZone
{
  Archiver_c *newArchiver = [super createBegin: aZone];
 
  newArchiver->applicationMap = [Map create: aZone];
  newArchiver->classes = [List create: aZone];
  newArchiver->instances = [List create: aZone];
  newArchiver->path = NULL;
  newArchiver->inhibitLoadFlag = NO;
  newArchiver->systemArchiverFlag = NO;
  
  return newArchiver;
}

+ create: aZone setPath: (const char *)thePath
{
  Archiver_c *obj = [self createBegin: aZone];
  obj->path = thePath;
  return [obj createEnd];
}

- setInhibitLoadFlag: (BOOL)theInhibitLoadFlag
{
  inhibitLoadFlag = theInhibitLoadFlag;
  return self;
}

- setPath: (const char *)thePath
{
  path = thePath;
  return self;
}

- setDefaultPath
{
  raiseEvent(SubclassMustImplement, "");
  return self;
}

- setDefaultAppPath
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- setSystemArchiverFlag: (BOOL)theSystemArchiverFlag
{
  systemArchiverFlag = theSystemArchiverFlag;
  return self;
}

PHASE(Setting)

PHASE(Using)

- createAppKey: (const char *)appName mode: (const char *)modeName
{
  id appKey = [String create: getZone (self) setC: appName];

  [appKey catC: "/"];
  [appKey catC: modeName];
  return appKey;
}

- ensureApp: appKey
{
  id app;
  
  if ((app = [applicationMap at: appKey]) == nil)
    {
      app = [[[Application createBegin: getZone (self)]
               setName: [appKey getC]]
              createEnd];
      
      [applicationMap at: appKey insert: app];
    }
  return app;
}
    
- getApplication
{
  id app = [applicationMap at: currentApplicationKey];
  
  if (app == nil)
    {
      app = [Application create: getZone (self)];
      [applicationMap at: currentApplicationKey insert: app];
    }
  return app;
}

- registerClient: client
{
  if (![client isInstance])
    {
      if (![classes contains: client])
        [classes addLast: client];
    }
  else if (![instances contains: client])
    [instances addLast: client];
  return self;
}

- unregisterClient: client
{
  if (![client isInstance])
    [classes remove: client];
  else
    [instances remove: client];
  return self;
}

- putDeep: (const char *)key object: object
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- putShallow: (const char *)key object: object
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- getObject: (const char *)key
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- getWithZone: aZone object: (const char *)key
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- (unsigned)countObjects: (BOOL)deepFlag
{
  id <MapIndex> index = [applicationMap begin: scratchZone];
  id app;
  id <String> appKey;
  unsigned count = 0;
  
  while ((app = [index next: &appKey]))
    count += [(deepFlag ? [app getDeepMap] : [app getShallowMap])
               getCount];
  [index drop];
  return count;
}

- updateArchiver
{
  id <Index> index;
  id item;
  IMP func = get_imp (id_CreatedClass_s, M(updateArchiver:));
  
  index = [classes begin: getZone (self)];
  while ((item = [index next]))
    func (item, M(updateArchiver:), self);
  [index drop];
  [instances forEach: @selector (updateArchiver:) : self];
  return self;
}

- save
{
  raiseEvent (SubclassMustImplement, "");
  return self;
}

- (void)drop
{
  [applicationMap deleteAll];
  [applicationMap drop];
  [classes drop];
  [instances drop];

  [super drop];
}

@end