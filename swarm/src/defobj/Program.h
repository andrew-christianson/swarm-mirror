// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         Program.h
Description:  metaobjects to describe loaded elements of a program
Library:      defobj
*/

#import <defobj/DefObject.h>
#import <defobj/Symbol.h>

extern id *_obj_classes;
extern unsigned _obj_nclasses;

extern void *_obj_initAlloc (size_t size);
extern void _obj_setTypeImplemented (id, id);

@interface Type_c: Object_s
{
@public
  id owner;            // module that contains type
  const char *name;    // name of type
  id *typeID;          // global id variable containing type
  id implementation;   // class that implements create phase, if any
  id supertypes;       // other types from which type inherits
}
/*** methods in Type_c (inserted from .m file by m2h) ***/
- (BOOL)getCreatable;
- getImplementation;
- (const char *)getName;
@end

@interface ProgramModule_c: Object
{
@public
  const char *name; // name of module
  id owner;         // module in which this module defined 
  id modules;       // modules defined within this module
  id types;         // types defined within module
  id symbols;       // symbols (global id constants) defined within module
  id classes;       // classes defined within module
}
/*** methods in ProgramModule_c (inserted from .m file by m2h) ***/
- (const char *)getName;
- getOwner;
- getModules;
- getTypes;
- getSymbols;
- getClasses;
@end

id defobj_lookup_type (const char *typename);

@interface Module_super_
/*** methods in Module_super_ (inserted from .m file by m2h) ***/
+ self;
@end