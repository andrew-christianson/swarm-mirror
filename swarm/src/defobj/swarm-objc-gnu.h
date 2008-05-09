// Swarm library. Copyright © 2008 Swarm Development Group.
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// 
// The Swarm Development Group can be reached via our website at:
// http://www.swarm.org/

/*
Name:         swarm-objc-gnu.h
Description:  Map Swarm ObjC API to GNU ObjC runtime
Library:      defobj
*/

#include <objc/objc.h>
#include <objc/objc-api.h>
#include <objc/encoding.h>
#include <objc/typedstream.h>
#include <objc/sarray.h>

//
// Direct mappings so use preprocessor defines
//

#define swarm_class_getName(cls) class_get_class_name(cls)
#define swarm_class_getMethodImplementation(cls, sel) get_imp(cls, sel)
#define swarm_class_getInstanceSize(cls) class_get_instance_size(cls)
#define swarm_class_getSuperclass(cls) class_get_super_class(cls)

#define swarm_method_getName(method) (((Method *)method)->method_name)
#define swarm_method_getImplementation(method) method_get_imp((Method *)method)
#define swarm_method_getTypeEncoding(method) (((Method *)method)->method_types)

#define swarm_objc_lookupClass(name) objc_lookup_class(name)

#define swarm_object_getClass(obj) object_get_class(obj)

#define swarm_sel_getName(sel) sel_get_name(sel)
#define swarm_sel_getTypeEncoding(sel) sel_get_type(sel)
#define swarm_sel_getTypedUid(str, types) sel_get_typed_uid(str, types)
#define swarm_sel_getUid(str) sel_get_uid(str)
#define swarm_sel_registerTypedName(str, types) sel_register_typed_name(str, types)
