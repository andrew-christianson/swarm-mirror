// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

//
// local.h -- defines and functions for use inside the objectbase lib
//

// SAFEPROBES enables lots of error checking here.
#define SAFEPROBES 1

//Used in order to ensure that probemaps do not reorder their contents 
//alphabetically...
extern int p_compare (id, id);
