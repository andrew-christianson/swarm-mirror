// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <objectbase.h> // VarProbe
#import <objectbase/Probe.h>

#include <swarmconfig.h>

@interface VarProbe: Probe <VarProbe>
{
  const char *probedVariable;
  int dataOffset;
  BOOL interactiveFlag;
  const char *floatFormat; // actual sprintf-type format

  unsigned rank;
  unsigned *dims;
  const char *baseType;

#ifdef HAVE_JDK
  JOBJECT *javaInfo;
#endif
  const void *getterMethod;
  const void *setterMethod;
}

- setProbedVariable: (const char *)aVariable;
- setProbedCOMgetter: (const void *)getter setter: (const void *)setter;
- createEnd;

- setNonInteractive;
- setStringReturnType: returnType;
- setFloatFormat: (const char *)format;

- (const char *)getProbedVariable;
- (int)getDataOffset;
- (BOOL)getInteractiveFlag;


- setStringReturnType: returnType;
- setFloatFormat: (const char *)format;

- (void *)probeRaw: anObject;
- probeObject: anObject;
- (void *)probeAsPointer: anObject;
- (int)probeAsInt: anObject;
- (double)probeAsDouble: anObject;
- (const char *)probeAsString: anObject Buffer: (char *)buffer;
- (id <String>)probeAsString: anObject;
- (const char *)probeAsString: nObject Buffer: (char *)buf 
            withFullPrecision: (BOOL)precision;

- (unsigned)getRank;
- (unsigned *)getDims;
- (const char *)getBaseType;

- iterateAsDouble: anObject using: (void (*) (unsigned rank, unsigned *vec, double val))func;
- iterateAsInteger: anObject using: (void (*) (unsigned rank, unsigned *vec, int val))func;

- (void)setData: anObject To: (void *)newValue;	      // pass by reference.
- (BOOL)setData: anObject ToString: (const char *)s;  // gives us the string.
- (void)setData: anObject ToDouble: (double)newValue;

- (void)drop;
- (void)describe: stream;
@end

