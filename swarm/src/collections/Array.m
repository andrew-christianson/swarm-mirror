// Swarm library. Copyright (C) 1996-1999 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         Array.m
Description:  implementation for Array type
Library:      collections
*/

#import <collections/Array.h>
#import <defobj/defalloc.h>
#import <collections.h> // INDEX{START,END}P

#include <misc.h> // memcpy

static void initArray (Array_c *self);

@implementation Array_c

PHASE(Creating)

+ createBegin: aZone
{
  return [aZone allocIVars: self];
}

- (void)setInitialValue: initialValue
{
  if (!respondsTo (initialValue, M(begin:)))
    raiseEvent (InvalidArgument, nil);
  
  setBit (bits, Bit_InitialValueSet, 1);
  if (bits & Bit_MemberAlloc)
    [self setMemberBlock: (id *) nil setCount: 0];
  
  block = (id *) initialValue;
}

- createEnd
{
  if (bits & Bit_MemberAlloc)
    {
      createByCopy ();
      setNextPhase (self);
    }
  else
    {
      if (createByMessageToCopy (self, createEnd))
        return self;
      initArray (self);
      setMappedAlloc (self);
      setNextPhase (self);
    }
  return self;
}

+ create: aZone setCount: (unsigned)memberCount;
{
  Array_c *newArray;

  if (memberCount < 0)
    raiseEvent (InvalidArgument, nil);
  
  newArray = [aZone allocIVars: getNextPhase (self)];
  setMappedAlloc (newArray);
  newArray->count = memberCount;
  initArray (newArray);
  return newArray;
}

+ create: aZone setMemberBlock: (id *)members setCount: (unsigned)memberCount;
{
  Array_c  *newArray;

  if (memberCount < 0)
    raiseEvent (InvalidArgument, nil);

  newArray = [aZone allocIVars: getNextPhase (self)];
  newArray->block = members;
  setBit (newArray->bits, Bit_MemberAlloc, 1);
  newArray->count = memberCount;
  return newArray;
}

static void
initArray (Array_c  *self)
{
  unsigned copyCount;
  id initialMembers = nil, indexSource, indexDest, *newBlock, *memptr;

  copyCount = 0;
  if (self->bits & Bit_InitialValueSet)
    {
      initialMembers = (id) self->block;
      copyCount = [initialMembers getCount];
      if (self->bits & Bit_CountSet)
        {
          if (copyCount > self->count)
            copyCount = self->count;
        }
      else
        self->count = copyCount;
    }

  {
    int allocCount = self->count;

    if (allocCount == 0)
      allocCount++;
    
    newBlock = [getZone (self) allocBlock:
                          ((self->bits & Bit_DefaultMember)
                           ? allocCount + 1 
                           :  allocCount) *
                        sizeof (id)];
  }
  // if DefaultMember, save current value of default member at end of block

  if (self->bits & Bit_DefaultMember)
    newBlock[self->count] = (id) self->block;
  
  self->block = newBlock;
  if (self->bits & Bit_InitialValueSet)
    {
      if (respondsTo (initialMembers, M(getMemberBlock)))
        memcpy (self->block,
                [initialMembers getMemberBlock],
                copyCount * sizeof (id));
      else
        {
          indexSource = [initialMembers begin: scratchZone];
          indexDest = [self begin: scratchZone];
          while (copyCount--)
            {
              [indexSource next];
              [indexDest next];
              [indexDest put: [indexSource get]];
            }
          [indexSource drop];
          [indexDest drop];
        }
      newBlock = self->block + copyCount;
    }
  
  if (self->bits & Bit_DefaultMember)
    {
      for (memptr = newBlock; memptr < (self->block + self->count); memptr++)
        *memptr = self->block[self->count];
    }
  else
    memset (newBlock, 0, (self->count - copyCount) * sizeof (id));
}

PHASE(Setting)

- (void)setMemberBlock: (id *)members setCount: (unsigned)memberCount
{
  if (getNextPhase (getClass (self)))
    { 
      // still in Creating Phase
      
      if (memberCount < 0)
        raiseEvent (InvalidArgument, nil);
      if (bits & Bit_InitialValueSet)
        raiseEvent (InvalidCombination,
                    "> cannot specify both an initial value and an external MemberAlloc\n");
      if (bits & Bit_DefaultMember)
        raiseEvent (InvalidCombination,
                    "> cannot specify both a DefaultMember and an external MemberAlloc\n");
      if (bits & Bit_CountSet)
        raiseEvent (SourceMessage,
                    "> cannot set array count separate from an external MemberAlloc\n");
      
      setBit (bits, Bit_MemberAlloc, 1);
      block = members;
      count = memberCount;
    }
  else
    { 
      // in Using phase
      
      if (!(bits & Bit_MemberAlloc))
        raiseEvent (SourceMessage,
                    "> cannot reset MemberAlloc unless originally specified at create time\n" );
      
      block = members;
      count = memberCount;
    }
}

- (void)setDefaultMember: memberValue
{
  if (getNextPhase (getClass (self)))
    { 
      // still in Creating Phase
      
      setBit (bits, Bit_DefaultMember, 1);
      if (bits & Bit_MemberAlloc)
        [self setMemberBlock: (id *) nil setCount: 0];
      block = (id *) memberValue;
      
    }
  else
    { 
      // in Using phase
      
      if (!(bits & Bit_DefaultMember))
        raiseEvent (SourceMessage,
                    "> cannot reset DefaultMember unless also specified at create time\n" );
      
      block[count] = memberValue;
    }
}

- setCount: (unsigned)memberCount
{
  id *newBlock, defaultMember, *memptr;
  id zone = getZone (self);

  if (getNextPhase (getClass (self)))
    { 
      // still Creating phase
      
      if (memberCount < 0)
        raiseEvent (InvalidArgument, nil);
      setBit (bits, Bit_CountSet, 1);
      if (bits & Bit_MemberAlloc)
        [self setMemberBlock: (id *) nil setCount: 0];
      count = memberCount;
    }
  else
    { 
      // in Using phase
      
      if (bits & Bit_MemberAlloc)
        raiseEvent (SourceMessage,
                    "> cannot set a new array count when using external MemberBlock\n");
      if (memberCount < 0)
        raiseEvent (InvalidArgument, nil);
      
      if (bits & Bit_DefaultMember)
        {
          newBlock = [zone allocBlock: (memberCount + 1) * sizeof (id)];
          newBlock[memberCount] = block[count];
          if (memberCount <= count)
            memcpy (newBlock, block, memberCount * sizeof (id));
          else
            {
              memcpy (newBlock, block, count * sizeof (id));
              defaultMember = block[count];
              for (memptr = newBlock + count;
                   memptr < (newBlock + memberCount);
                   memptr++)
                *memptr = defaultMember;
            }
          [zone freeBlock: block blockSize: (count + 1) * sizeof (id)];
        }
      else
        {
          newBlock = [zone allocBlock: memberCount * sizeof (id)];
          if (memberCount <= count)
            memcpy (newBlock, block, memberCount * sizeof (id));
          else
            {
              memcpy (newBlock, block, count * sizeof (id));
              memset (newBlock + count, 0,
                      (memberCount - count) * sizeof (id));
            }
          [zone freeBlock: block blockSize: count * sizeof (id)];
        }
      block = newBlock;
      count = memberCount;
    }
  return self;
}

PHASE(Using)
     
- (void *)getMemberBlock
{
  return block;
}

- getDefaultMember
{
  if (bits & Bit_DefaultMember)
    return block[count];
  return nil;
}

- (unsigned)getCount
{
  return count;
}

- (unsigned)count
{
  return count;
}

- atOffset: (unsigned)offset
{
  if (offset >= count)
    raiseEvent (OffsetOutOfRange, nil);
  return block[offset];
}

- atOffset: (unsigned)offset put: anObject
{
  id oldMember;
  
  if (offset >= count)
    raiseEvent (OffsetOutOfRange, nil);
  oldMember = block[offset];
  block[offset] = anObject;
  return oldMember;
}

- getFirst
{
  if (count <= 0)
    raiseEvent (OffsetOutOfRange, nil);
  return block[0];
}

- getLast
{
  if (count <= 0)
    raiseEvent (OffsetOutOfRange, nil);
  return block[count - 1];
}

- begin: aZone
{
  ArrayIndex_c *newIndex;

  newIndex = [aZone allocIVars: id_ArrayIndex_c];
  newIndex->collection = self;
  newIndex->memPtr = (id *) Start;
  return newIndex;
}

- copy: aZone
{
  Array_c *newArray;
  int copyCount;

  newArray = [aZone copyIVars: self];

  copyCount = getBit (bits, Bit_DefaultMember) ? count + 1 : count;
  newArray->block = [aZone allocBlock: copyCount * sizeof (id)];
  memcpy (newArray->block, block, copyCount * sizeof (id));
  setBit (newArray->bits, Bit_MemberAlloc, 0);
  return newArray;
}

//
// describe: -- standard method to generate debug description of object
//
- (void)describe: outputCharStream
{
  char buffer[100];
  
  [super describe: outputCharStream];
  if (getBit (bits, Bit_MemberAlloc))
    {
      sprintf (buffer, "> external member allocation at: " PTRFMT "\n",
               block);
      [outputCharStream catC: buffer];
    }
  else if (getBit (bits, Bit_DefaultMember))
    {
      sprintf( buffer, "> default member value: " PTRFMT "\n",
               block[count] );
      [outputCharStream catC: buffer];
    }
}

//
// mapAllocations: -- standard method to identify internal allocations
//
- (void) mapAllocations: (mapalloc_t)mapalloc
{
  if (!includeBlocks (mapalloc) || (bits & Bit_MemberAlloc))
    return;

  mapalloc->size =
    ((bits & Bit_DefaultMember) ? count + 1 : count) * sizeof (id);
  mapAlloc (mapalloc, block);
}

@end


// ArrayIndex_c: index for Array_c

@implementation ArrayIndex_c
PHASE(Creating)
PHASE(Using)
- next
{
  if (INDEXENDP (memPtr))
    raiseEvent (AlreadyAtEnd, nil);

  if (INDEXSTARTP (memPtr))
    memPtr = ((Array_c *) collection)->block;
  else
    memPtr++;
  if (memPtr >= (((Array_c *) collection)->block +
                 ((Array_c *) collection)->count))
    {
      memPtr = (id *) End;
      return nil;
    }
  return *memPtr;
}

- prev
{
  if (INDEXSTARTP (memPtr))
    raiseEvent (AlreadyAtEnd, nil);
  
  if (INDEXENDP (memPtr))
    memPtr = ((Array_c *) collection)->block + ((Array_c *) collection)->count;
  
  memPtr--;
  if (memPtr < ((Array_c *) collection)->block)
    {
      memPtr = (id *) Start;
      return nil;
    }
  return *memPtr;
}

- get
{
  if (INDEXSTARTP (memPtr) || INDEXENDP (memPtr))
    return nil;
  return *memPtr;
}

- put: anObject
{
  id oldMember;

  if (INDEXSTARTP (memPtr) || INDEXENDP (memPtr))
    return nil;

  oldMember = *memPtr;
  *memPtr = anObject;
  return oldMember;
}

- remove
{
  raiseEvent (SourceMessage,
              "> remove is not supported on any Array - can only replace members\n");
  exit (1);
}

- (id <Symbol>)getLoc
{
  if (INDEXSTARTP (memPtr) || INDEXENDP (memPtr))
    return (id)memPtr;

  return Member;
}

- (void)setLoc: (id <Symbol>)locSymbol
{
  if (INDEXSTARTP (locSymbol))
    memPtr = (id *) Start;
  else if (INDEXENDP (locSymbol))
    memPtr = (id *) End;
  else
    raiseEvent (InvalidArgument, nil);
}

- (int)getOffset
{
  if (INDEXSTARTP (memPtr) || INDEXENDP (memPtr))
    return -1;
  return memPtr - ((Array_c *) collection)->block;
}

- setOffset: (unsigned)offset
{
  if (offset >= ((Array_c *) collection)->count)
    raiseEvent (OffsetOutOfRange, nil);
  memPtr = ((Array_c *) collection)->block + offset;
  return *memPtr; 
}

- (int)compare: anIndex
{
  if (_obj_debug
      && (!respondsTo (anIndex, M(getCollection))
          || ((ArrayIndex_c *) anIndex)->collection != collection))
    raiseEvent (InvalidArgument, nil);
  
  if (memPtr > ((ArrayIndex_c *) anIndex)->memPtr)
    return 1;

  return memPtr < ((ArrayIndex_c *) anIndex)->memPtr;
}

@end

