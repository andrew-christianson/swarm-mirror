// Swarm library. Copyright � 1996-1999 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         List.m
Description:  implementations for List type
Library:      collections
*/

#import <collections/List.h>
#import <defobj/defalloc.h>
#import <defobj.h> // SaveError

#include <collections/predicates.h> // keywordp
#include <misc.h> // abort

@implementation List_any

PHASE(Creating)

+ createBegin: aZone
{
  List_any *newList;

  newList = [aZone allocIVars: self];
  return newList;
}

- (void)setInitialValue: initialValue
{
  firstLink = (link_t) initialValue;
  setBit (bits, Bit_InitialValueSet, 1);
}

- (void)setDequeOnly: (BOOL)dequeOnly
{
  setBit (bits, Bit_DequeOnly, dequeOnly);
}

static void
setListClass (id obj, id aClass)
{
  Class_s *nextPhase = id_List_any;

  if (getBit (getClass (obj)->info, _CLS_DEFINEDCLASS))
    nextPhase = ((BehaviorPhase_s *) getClass (obj))->nextPhase;
  
  if (nextPhase == id_List_any)
    nextPhase = aClass;
  
  setClass (obj, nextPhase);
}

- createEnd
{
  id index, member;

  if ((bits & Bit_InitialValueSet) && (bits & Bit_IndexFromMemberLoc))
    raiseEvent (InvalidCombination,
                "> cannot specify an initial value with IndexFromMemberLoc option\n");
  
  if (bits & Bit_InitialValueSet)
    {
      if (createByMessageToCopy (self, createEnd))
        return self;
      setListClass (self, id_List_linked);
      setMappedAlloc (self);
      index = [(id) firstLink begin: scratchZone];
      firstLink = NULL;
      for (member = [index next];
           [index getLoc] == Member;
           member = [index next])
        [(id) self addLast: member];
      [index drop];
    }
  else
    {
      createByCopy ();
      if (bits & Bit_IndexFromMemberLoc)
        setListClass (self, id_List_mlinks);
      else
        setListClass (self, id_List_linked);
      setMappedAlloc (self);
    }
  return self;
}

- lispInCreate: expr
{
  id index, member;

  index = [(id) expr begin: scratchZone];
  for (member = [index next];
       [index getLoc] == Member;
       member = [index next])
    {
      if (keywordp (member))
        {
          const char *name = [member getKeywordName];

          if (strcmp (name, "index-from-member-loc") == 0)
            [self setIndexFromMemberLoc: lispInInteger (index)];
          else if (strcmp (name, "initial-value-set") == 0)
            [self setInitialValue: lispIn ([self getZone], [index next])];
          else if (![self _lispInAttr_: index])
            raiseEvent (InvalidArgument, "unknown keyword `%s'", name);
        }
    }
  [index drop];
  return self;
}

- hdf5InCreate: hdf5Obj
{
  return self;
}


PHASE(Setting)

- (void)setCountPerBlock: (int)countPerBlock
{
  raiseEvent (NotImplemented, nil);
}

- lispIn: expr
{
  id index, member;

  index = [(id) expr begin: scratchZone];
  for (member = [index next]; [index getLoc] == Member; member = [index next])
    if (keywordp (member))
      [index next];
    else
      [(id) self addLast: lispIn ([self getZone], member)];
  [index drop];
  return self;
}

- hdf5In: hdf5Obj
{
  if ([hdf5Obj getDatasetFlag])
    {
      id aZone = [self getZone];
      Class class = [hdf5Obj getClass];
      unsigned i, c_count = [hdf5Obj getCount];

      for (i = 0; i < c_count; i++)
        {
          id obj = [class create: aZone];

          [hdf5Obj selectRecord: i];
          [hdf5Obj shallowLoadObject: obj];
          [(id) self addLast: obj];
        }
    }
  else
    {
      int process_object (id component)
        {
          [(id) self addLast: hdf5In ([self getZone], component)];
          return 0;
        }
      [hdf5Obj iterate: process_object];
    }
  return self;
}

PHASE(Using)

- (BOOL)getDequeOnly
{
  return bits & Bit_DequeOnly;
}

- (unsigned)getCountPerBlock
{
  raiseEvent (NotImplemented, nil);
  
  abort ();
}

- _lispOut_: outputCharStream deep: (BOOL)deepFlag
{
  id index, member;

  [outputCharStream catStartMakeInstance: [self getTypeName]];
  [outputCharStream catSeparator];
  index = [(id) self begin: scratchZone];
  if (deepFlag)
    {
      for (member = [index next];
           [index getLoc] == Member; 
           member = [index next])
        if (member)
          [member lispOutDeep: outputCharStream];
    }
  else
    {
      for (member = [index next];
           [index getLoc] == Member; 
           member = [index next])
        if (member)
          [member lispOutShallow: outputCharStream];
    }
  [index drop];

  [self _lispOutAttr_: outputCharStream];

  if (bits & Bit_IndexFromMemberLoc)
    {
      [outputCharStream catSeparator];
      [outputCharStream catKeyword: "index-from-member-loc"];
      [outputCharStream catSeparator];
      [outputCharStream catInt: [self getIndexFromMemberLoc]];
    }

#if 0
  if (bits & Bit_InitialValueSet)
    {
      // Would need to preserve original setting...
      [outputCharStream catC: "#:initial-value-set "];
    }
#endif
  
  [outputCharStream catEndExpr];
  
  return self;
}

- lispOutDeep: stream
{
  return [self _lispOut_: stream deep: YES];
}

- lispOutShallow: stream
{
  return [self _lispOut_: stream deep: NO];
}

- hdf5OutDeep: hdf5Obj
{
  id aZone = [self getZone];

  id <Index> li = [self begin: scratchZone];
  id member;
  
  [hdf5Obj storeTypeName: [self getTypeName]];
  while ((member = [li next]))
    {
      id itemGroup;
      char buf[DSIZE (unsigned) + 1];
      
      sprintf (buf, "%u", [li getOffset]);
      
      itemGroup = [[[[[HDF5 createBegin: aZone]
                       setParent: hdf5Obj]
                      setWriteFlag: YES]
                     setName: buf]
                    createEnd];
      
      [member hdf5OutDeep: itemGroup];
      [itemGroup drop];
    }
  [li drop];

  return self;
}

- hdf5OutShallow: hdf5Obj
{
  if (![self allSameClass])
    raiseEvent (SaveError,
                "shallow HDF5 serialization on Collections must be same type");
  else
    {
      id aZone = [self getZone];
      id memberProto = [self getFirst];
      id hdf5CompoundType = [[[HDF5CompoundType createBegin: aZone]
                               setPrototype: memberProto]
                              createEnd];
      
      id hdf5ObjDataset =
        [[[[[[[HDF5 createBegin: aZone]
               setName: [hdf5Obj getName]]
              setParent: hdf5Obj]
             setWriteFlag: YES]
            setCompoundType: hdf5CompoundType]
           setCount: [self getCount]]
          createEnd];
      
      [hdf5ObjDataset storeTypeName: [self getTypeName]];
      [hdf5ObjDataset storeComponentTypeName: [memberProto getTypeName]];
      {
        id <Index> li = [self begin: scratchZone];
        id member;
        
        while ((member = [li next]))
          {
            unsigned rn = [li getOffset];
            
            [hdf5ObjDataset numberRecord: rn];
            [hdf5ObjDataset selectRecord: rn];
            [member hdf5OutShallow: hdf5ObjDataset];
          }
        [li drop];
      }
      [hdf5ObjDataset writeRowNames];
      [hdf5ObjDataset writeLevels];
      [hdf5ObjDataset drop];
      [hdf5CompoundType drop];
    }
  return self;
}

@end


// ListIndex_any: index for List_c

@implementation ListIndex_any
@end