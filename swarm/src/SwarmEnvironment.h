#import <swarm.h>

#import <defobj.h>
#import <collections.h>
#import <objectbase.h>
#import <random.h>
#import <simtools.h>
#import <simtoolsgui.h>
#import <defobj/Create.h>

@interface SwarmEnvironment: CreateDrop <SwarmEnvironment>
{
  id <Arguments> arguments;
  BOOL forceBatchMode;
}
+ createBegin;
- setArguments: (id <Arguments>)arguments;
- setBatchMode: (BOOL)batchMode;
- createEnd;
- (void)initSwarm: (const char *)appName version: (const char *)version bugAddress: (const char *)bugAddress args: (const char **)args;

- (timeval_t)getCurrentTime;
- (id <SwarmActivity>)getCurrentSwarmActivity;

- (void)createProbeDisplay: obj;
- (void)createCompleteProbeDisplay: obj;
- (void)createArchivedProbeDisplay: obj name: (const char *)name;
- (void)createArchivedCompleteProbeDisplay: obj name: (const char *)name;
- (void)setWindowGeometryRecordName: obj name: (const char *)name;
- (void)setComponentWindowGeometryRecordNameFor: obj widget: widget name: (const char *)name;
- (void)setComponentWindowGeometryRecordName: widget name: (const char *)name;
- (void)xprint: obj;
- (void)xfprint: obj;
- (void)dumpDirectory;

#import "SwarmEnvironment_getters.h"
@end