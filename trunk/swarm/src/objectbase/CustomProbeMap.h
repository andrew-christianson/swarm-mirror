// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

// place holder for a map of probes. This will be replaced with the
// generic Map class. Given a class, build an array of probe objects that
// work on that class (one per variable).

#import <objectbase/ProbeMap.h>

@interface CustomProbeMap: ProbeMap <CustomProbeMap>
{
}
+ create: aZone forClass: (Class)aClass 
withIdentifiers: (const char *)vars, ...;
- createEnd;
- addProbesForClass: (Class) aClass 
    withIdentifiers:  (const char *)vars, ...;

@end

