// Swarm library. Copyright (C) 1996 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <simtools/ProbeDisplayManager.h>
#import <swarmobject/SwarmObject.h>
#import <random.h>

// global random number generators (defaults)
extern id <PMMLCG1> randomGenerator;
extern id <UniformInteger> uniformIntRand;
extern id <UniformUnsigned> uniformUnsRand;
extern id <UniformDouble> uniformDblRand;

// Manager that keeps track of active probes to be updated
extern ProbeDisplayManager * probeDisplayManager;

void initSwarm(int argc, char ** argv);

// Flag for whether we're in graphics mode or not. Default is 1.
extern int swarmGUIMode;