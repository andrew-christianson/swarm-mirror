// Swarm library. Copyright � 1997-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <simtools/QSort.h>
#import <collections.h>

#include <misc.h> // quicksort

#include <swarmconfig.h> // PTRINT

@implementation QSort

static id *flat;
static size_t size;
static SEL comp_selector;

PHASE(Creating)
PHASE(Using)

+ (void)_flatten_: aCollection
{
  id index;  //atOffset would cause repetitive traversal in lists etc.
  size_t i;

  size = [aCollection getCount];
  if (size)
    {
      flat = [scratchZone alloc: sizeof (id) * size];
      
      index = [aCollection begin: scratchZone];
      
      for (i = 0; i < size; i++)
        flat[i] = [index next];
      
      [index drop];
    }
}

+ (void)_unFlatten_: aCollection
{
  id index; // atOffset would cause repetitive traversal in lists etc.
  size_t i;
  
  index = [aCollection begin: scratchZone];
  for (i = 0; i < size; i++)
    {
      [index next];
      [index put: flat[i]]; 
    }
  
  [index drop];
  [scratchZone free: flat];
}

static int
defaultCmpObjs (id *a, id *b)
{
  return [*a compare: *b];
}

static int
cmpInts (PTRINT *a, PTRINT *b)
{
  if (*a > *b)
    return 1;
  
  if (*a == *b)
    return 0;
  
  return -1;
}

static int
cmpObjs (id *a, id *b)
{
  return (int) (PTRINT) [*a perform: comp_selector with: *b];
}

+ (void)sortObjectsIn: aCollection
{
  [self _flatten_: aCollection];

  if (size)
    {
      quicksort (flat, size, sizeof (id),
                 (quicksort_compar_fn_t) defaultCmpObjs);
      [self _unFlatten_: aCollection];
    }
}

+ (void)sortNumbersIn: aCollection
{
  [self _flatten_: aCollection];

  if (size)
    {
      quicksort (flat, size, sizeof (PTRINT),
                 (quicksort_compar_fn_t) cmpInts);
      [self _unFlatten_: aCollection];
    }
}

+ (void)sortObjectsIn: aCollection using: (SEL)aSelector
{
  [self _flatten_: aCollection];
  
  if (size)
    {
      comp_selector = aSelector;
      quicksort (flat, size, sizeof (id),
                 (quicksort_compar_fn_t) cmpObjs);
      [self _unFlatten_: aCollection];
    }
}

+ (void)sortNumbersIn: aCollection
                using: (int (*) (const void *, const void *)) comp_fun
{
  [self _flatten_: aCollection];

  if (size)
    {
      quicksort (flat, size, sizeof (PTRINT),
                 (quicksort_compar_fn_t) comp_fun);
      [self _unFlatten_: aCollection];
    }
}

+ (void)reverseOrderOf: aCollection
{
  id index;  // atOffset would cause repetitive traversal in lists etc.
  size_t i;
  
  // Do `flatten':
  
  size = [aCollection getCount];
  
  if (size)
    {
      flat = [scratchZone alloc: sizeof (id) * size];
      
      index = [aCollection begin: scratchZone];
      
      for (i = 0; i < size; i++)
        flat[i] = [index next];
      
      // Now do a modified `unflatten':
      
      [index setLoc: Start]; // no need to re-create the index
      
      for (i = 0; i < size; i++)
        {
          [index next];
          [index put: flat[size - 1 - i]];
        }
      
      [index drop];
      [scratchZone free: flat];
    }
}

@end