// By Sven Thommesen <sthomme@humsci.auburn.edu>
// "HumbugModelSwarm.m"

// Import Swarm libraries:

#import <math.h>
#import <space.h>
#import <activity.h>
#import <collections.h>
#import <swarmobject.h>
#import <simtools.h>
#import <random.h>

#import "HumbugModelSwarm.h"

// HumbugModelSwarm.m.8:
// Simple informational output for each object 
// Usage: './humbug -batchmode > runlog'


@implementation HumbugModelSwarm

+createBegin: (id) aZone {
  HumbugModelSwarm * obj;

  obj = [super createBegin: aZone];

  obj->debugPrint = 1;

  obj->myStream = [ OutputStream create: aZone setFileStream: stdout ];

  return obj;
}

-createEnd {
  return [super createEnd];
}

-genTest7: (id) myGenerator {
   unsigned max,bits;

   max = [myGenerator getUnsignedMax];

        if (max > (1U << 31)) bits = 32;
   else if (max > (1U << 30)) bits = 31;
   else if (max > (1U << 29)) bits = 30;
   else if (max > (1U << 28)) bits = 29;
   else if (max > (1U << 27)) bits = 28;
   else bits = 27;

   printf("%16s unsignedMax = %12u  (%2d bits) \n",
	[myGenerator getName], max, bits);

   return self;
}

-genDisplay7: (id) myGenerator {

   [myGenerator describe: myStream];
   [myStream catC: "\f\n"];

   return self;
}

-distDisplay7: (id) myDistribution {

   [myDistribution describe: myStream];
   // [[myDistribution getGenerator] describe: myStream];
   [myStream catC: "\f\n"];

   return self;
}

-buildObjects {
  unsigned int mySeeds[1024];
  int i,j;
  id myGen1, myGen2, myGen3, myGen4, myGen5;
 
  [super buildObjects];

  // printf(" Create generators: \n");

  mySeeds[0] = DEFAULTSEED1;
  mySeeds[1] = DEFAULTSEED2;
  mySeeds[2] = DEFAULTSEED3;
  mySeeds[3] = DEFAULTSEED4;

  printf("DEFAULTSEED  = %12u\n", DEFAULTSEED);
  printf("DEFAULTSEED1 = %12u\n", DEFAULTSEED1);
  printf("DEFAULTSEED2 = %12u\n", DEFAULTSEED2);
  printf("DEFAULTSEED3 = %12u\n", DEFAULTSEED3);
  printf("DEFAULTSEED4 = %12u\n", DEFAULTSEED4);
  printf("\n");

  printf("useFixedSeed = %12d\n", _useFixedSeed);
  printf("firstSeed    = %12u\n", _firstSeed);
  printf("\n");

  printf("Clocks per sec = %d so clock step = %d microseconds\n\n", 
     CLOCKS_PER_SEC, 1000000 / CLOCKS_PER_SEC);

  printf("getpid = %d\n\n", getpid());

  printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
  printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
  printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
  printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
  printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
  printf("\n");

printf("tempusFugit = %12u\n", tempusFugit());
printf("tempusFugit = %12u\n", tempusFugit());
printf("tempusFugit = %12u\n", tempusFugit());
printf("tempusFugit = %12u\n", tempusFugit());
printf("tempusFugit = %12u\n", tempusFugit());
printf("\n");

i = sleep(1);
printf("sleep+tempusFugit = %12u\n", tempusFugit());
i = sleep(1);
printf("sleep+tempusFugit = %12u\n", tempusFugit());
i = sleep(1);
printf("sleep+tempusFugit = %12u\n", tempusFugit());
i = sleep(1);
printf("sleep+tempusFugit = %12u\n", tempusFugit());
i = sleep(1);
printf("sleep+tempusFugit = %12u\n", tempusFugit());
printf("\n");

printf("time = %12ld\n", time(0));
printf("time = %12ld\n", time(0));
printf("time = %12ld\n", time(0));
printf("time = %12ld\n", time(0));
printf("time = %12ld\n", time(0));
printf("\n");

printf("clock = %12ld\n", clock());
printf("clock = %12ld\n", clock());
printf("clock = %12ld\n", clock());
printf("clock = %12ld\n", clock());
printf("clock = %12ld\n", clock());
printf("\n");

i = sleep(1);
printf("sleep+clock = %12ld\n", clock());
i = sleep(1);
printf("sleep+clock = %12ld\n", clock());
i = sleep(1);
printf("sleep+clock = %12ld\n", clock());
i = sleep(1);
printf("sleep+clock = %12ld\n", clock());
i = sleep(1);
printf("sleep+clock = %12ld\n", clock());
printf("\n");

for (i=0; i<1000; i++) j=i;
printf("delay+clock = %12ld\n", clock());
for (i=0; i<1000; i++) j=i;
printf("delay+clock = %12ld\n", clock());
for (i=0; i<1000; i++) j=i;
printf("delay+clock = %12ld\n", clock());
for (i=0; i<1000; i++) j=i;
printf("delay+clock = %12ld\n", clock());
for (i=0; i<1000; i++) j=i;
printf("delay+clock = %12ld\n", clock());
printf("\n");

printf("CHICKENFEED = %12u\n", CHICKENFEED);
printf("CHICKENFEED = %12u\n", CHICKENFEED);
printf("CHICKENFEED = %12u\n", CHICKENFEED);
printf("CHICKENFEED = %12u\n", CHICKENFEED);
printf("CHICKENFEED = %12u\n", CHICKENFEED);
printf("\n");

printf("BIRDSEED    = %12u\n", BIRDSEED);
printf("BIRDSEED    = %12u\n", BIRDSEED);
printf("BIRDSEED    = %12u\n", BIRDSEED);
printf("BIRDSEED    = %12u\n", BIRDSEED);
printf("BIRDSEED    = %12u\n", BIRDSEED);
printf("\n");

printf("SLEEPYSEED  = %12u\n", SLEEPYSEED);
printf("SLEEPYSEED  = %12u\n", SLEEPYSEED);
printf("SLEEPYSEED  = %12u\n", SLEEPYSEED);
printf("SLEEPYSEED  = %12u\n", SLEEPYSEED);
printf("SLEEPYSEED  = %12u\n", SLEEPYSEED);
printf("\n");

printf("PIDTIMESEED = %12u\n", PIDTIMESEED);
printf("PIDTIMESEED = %12u\n", PIDTIMESEED);
printf("PIDTIMESEED = %12u\n", PIDTIMESEED);
printf("PIDTIMESEED = %12u\n", PIDTIMESEED);
printf("PIDTIMESEED = %12u\n", PIDTIMESEED);
printf("\n");

printf("PIDRANDSEED = %12u\n", PIDRANDSEED);
printf("PIDRANDSEED = %12u\n", PIDRANDSEED);
printf("PIDRANDSEED = %12u\n", PIDRANDSEED);
printf("PIDRANDSEED = %12u\n", PIDRANDSEED);
printf("PIDRANDSEED = %12u\n", PIDRANDSEED);
printf("\n");

printf("FIRSTSEED   = %12u\n", FIRSTSEED);
printf("\n");

printf("NEXTSEED    = %12u\n", NEXTSEED);
printf("NEXTSEED    = %12u\n", NEXTSEED);
printf("NEXTSEED    = %12u\n", NEXTSEED);
printf("NEXTSEED    = %12u\n", NEXTSEED);
printf("NEXTSEED    = %12u\n", NEXTSEED);
printf("\n");

printf("RANDOMSEED  = %12u\n", RANDOMSEED);
printf("RANDOMSEED  = %12u\n", RANDOMSEED);
printf("RANDOMSEED  = %12u\n", RANDOMSEED);
printf("RANDOMSEED  = %12u\n", RANDOMSEED);
printf("RANDOMSEED  = %12u\n", RANDOMSEED);
printf("\n");


printf("STARTSEED   = %12u\n", STARTSEED);
printf("STARTSEED   = %12u\n", STARTSEED);
printf("STARTSEED   = %12u\n", STARTSEED);
printf("STARTSEED   = %12u\n", STARTSEED);
printf("STARTSEED   = %12u\n", STARTSEED);
printf("\n");

printf("Creating new generators:\n\n");
myGen1 = [PMMLCG1gen createWithDefaults: [self getZone]];
printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
myGen2 = [PMMLCG1gen createWithDefaults: [self getZone]];
printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
myGen3 = [PMMLCG1gen createWithDefaults: [self getZone]];
printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
myGen4 = [PMMLCG1gen createWithDefaults: [self getZone]];
printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
myGen5 = [PMMLCG1gen createWithDefaults: [self getZone]];
printf("time = %ld   clock = %ld   tempusFugit = %u\n", 
	time(0), clock(), tempusFugit()  );
printf("\n");

// printf("\f\n");

// SIMPLE generators:

/*
// -----
  // myGen = [PMMLCG1gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG1gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG1gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG1gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG2gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG2gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG2gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG2gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG3gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG3gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG3gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG3gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG4gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG4gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG4gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG4gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG5gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG5gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG5gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG5gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG6gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG6gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG6gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG6gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG7gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG7gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG7gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG7gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG8gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG8gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG8gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG8gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PMMLCG9gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PMMLCG9gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PMMLCG9gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PMMLCG9gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [LCG1gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [LCG1gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [LCG1gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [LCG1gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [LCG2gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [LCG2gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [LCG2gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [LCG2gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [LCG3gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [LCG3gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [LCG3gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [LCG3gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [ACGgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [ACGgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [ACGgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [ACGgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [SCGgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [SCGgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [SCGgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [SCGgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [SWB1gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [SWB1gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [SWB1gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [SWB1gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [SWB2gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [SWB2gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [SWB2gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [SWB2gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [SWB3gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [SWB3gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [SWB3gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [SWB3gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [PSWBgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [PSWBgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [PSWBgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [PSWBgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MRG5gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MRG5gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MRG5gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MRG5gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MRG6gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MRG6gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MRG6gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MRG6gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MRG7gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MRG7gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MRG7gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MRG7gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [C2MRG3gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [C2MRG3gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [C2MRG3gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [C2MRG3gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [C2TAUS1gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [C2TAUS1gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [C2TAUS1gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [C2TAUS1gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [C2TAUS2gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [C2TAUS2gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [C2TAUS2gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [C2TAUS2gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [C2TAUS3gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [C2TAUS3gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [C2TAUS3gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [C2TAUS3gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [TT403gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [TT403gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [TT403gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [TT403gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [TT775gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [TT775gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [TT775gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [TT775gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [TT800gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [TT800gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [TT800gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [TT800gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MT19937gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MT19937gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MT19937gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MT19937gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MWCAgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MWCAgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MWCAgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MWCAgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [MWCBgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [MWCBgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [MWCBgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [MWCBgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [C3MWCgen create: [self getZone] setStateFromSeed: 1];
  // myGen = [C3MWCgen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [C3MWCgen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [C3MWCgen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [RWC2gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [RWC2gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [RWC2gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [RWC2gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
  // myGen = [RWC8gen create: [self getZone] setStateFromSeed: 1];
  // myGen = [RWC8gen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [RWC8gen create: [self getZone] setStateFromSeeds: mySeeds];
  myGen = [RWC8gen createWithDefaults: [self getZone]];
  [self genDisplay7: myGen];
// -----
*/
  // myGen = [RWC8Ugen create: [self getZone] setStateFromSeed: 1];
  // myGen = [RWC8Ugen create: [self getZone] setStateFromSeed: RANDOMSEED];
  // myGen = [RWC8Ugen create: [self getZone] setStateFromSeeds: mySeeds];
    // myGen = [RWC8Ugen createWithDefaults: [self getZone]];
    // [self genDisplay7: myGen];
// -----
/*
*/

// SPLIT generators:

/*
// -----
  // myGen = [C2LCGXgen create: [self getZone] 
  // 		setA: 32 setv: 20 setw: 30
  // 		setStateFromSeed: 1];
  // myGen = [C2LCGXgen create: [self getZone] 
  // 		setA: 32 setv: 20 setw: 30
  // 		setStateFromSeed: RANDOMSEED];
  // myGen = [C2LCGXgen create: [self getZone] 
  // 		setA: 32 setv: 20 setw: 30
  // 		setStateFromSeeds: mySeeds];
  myGen = [C2LCGXgen createWithDefaults: [self getZone]];

  [self genDisplay7: myGen];
// -----
  // myGen = [C4LCGXgen create: [self getZone] 
  // 		setA: 128 setv: 31 setw: 41
  // 		setStateFromSeed: 1];
  // myGen = [C4LCGXgen create: [self getZone] 
  // 		setA: 128 setv: 31 setw: 41
  // 		setStateFromSeed: RANDOMSEED];
  // myGen = [C4LCGXgen create: [self getZone] 
  // 		setA: 128 setv: 31 setw: 41
  // 		setStateFromSeeds: mySeeds];
  myGen = [C4LCGXgen createWithDefaults: [self getZone]];

  [self genDisplay7: myGen];
// -----
*/

   mySimpleGen = [PMMLCG1gen createWithDefaults: [self getZone]];
   mySplitGen  = [C4LCGXgen  createWithDefaults: [self getZone]];

// DISTRIBUTIONS:

/*
// -----
  myDist = [RandomBitDist createWithDefaults: [self getZone]];
  // myDist = [RandomBitDist create: [self getZone] setGenerator: mySimpleGen];
  // myDist = [RandomBitDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];

  [self distDisplay7: myDist];
// -----
  myDist = [BernoulliDist createWithDefaults: [self getZone]];
  // myDist = [BernoulliDist create: [self getZone] setGenerator: mySimpleGen];
  // myDist = [BernoulliDist create: [self getZone] setGenerator: mySimpleGen
  //		setProbability: 0.67];
  // myDist = [BernoulliDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [BernoulliDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setProbability: 0.67];

  [self distDisplay7: myDist];
// -----
  myDist = [UniformIntegerDist createWithDefaults: [self getZone]];
  // myDist = [UniformIntegerDist create: [self getZone] 
  // 		setGenerator: mySimpleGen];
  // myDist = [UniformIntegerDist create: [self getZone] 
  //		setGenerator: mySimpleGen
  //		setIntegerMin: -33 setMax: 78 ];
  // myDist = [UniformIntegerDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [UniformIntegerDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setIntegerMin: -33 setMax: 78 ];

  [self distDisplay7: myDist];
// -----
  myDist = [UniformUnsignedDist createWithDefaults: [self getZone]];
  // myDist = [UniformUnsignedDist create: [self getZone] 
  // 		setGenerator: mySimpleGen];
  // myDist = [UniformUnsignedDist create: [self getZone] 
  //		setGenerator: mySimpleGen
  //		setUnsignedMin: 28 setMax: 61 ];
  // myDist = [UniformUnsignedDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [UniformUnsignedDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setUnsignedMin: 28 setMax: 61 ];

  [self distDisplay7: myDist];
// -----
  myDist = [UniformDoubleDist createWithDefaults: [self getZone]];
  // myDist = [UniformDoubleDist create: [self getZone] 
  // 		setGenerator: mySimpleGen];
  // myDist = [UniformDoubleDist create: [self getZone] 
  //		setGenerator: mySimpleGen
  //		setDoubleMin: 3.14159 setMax: 2.81218 ];
  // myDist = [UniformDoubleDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [UniformDoubleDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setDoubleMin: 3.14159 setMax: 2.81218 ];

  [self distDisplay7: myDist];
// -----
  myDist = [NormalDist createWithDefaults: [self getZone]];
  // myDist = [NormalDist create: [self getZone] setGenerator: mySimpleGen];
  // myDist = [NormalDist create: [self getZone] setGenerator: mySimpleGen
  //		setMean: 3.0 setVariance: 1.5 ];
  // myDist = [NormalDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [NormalDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setMean: 3.0 setVariance: 1.5];

  [self distDisplay7: myDist];
// -----
  myDist = [LogNormalDist createWithDefaults: [self getZone]];
  // myDist = [LogNormalDist create: [self getZone] setGenerator: mySimpleGen];
  // myDist = [LogNormalDist create: [self getZone] setGenerator: mySimpleGen
  //		setMean: 3.0 setVariance: 1.5 ];
  // myDist = [LogNormalDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [LogNormalDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setMean: 3.0 setVariance: 1.5];

  [self distDisplay7: myDist];
// -----
  myDist = [ExponentialDist createWithDefaults: [self getZone]];
 // myDist = [ExponentialDist create: [self getZone] setGenerator: mySimpleGen];
 // myDist = [ExponentialDist create: [self getZone] setGenerator: mySimpleGen
 //		setMean: 3.0 ];
 // myDist = [ExponentialDist create: [self getZone]
 // 		setGenerator: mySplitGen setVirtualGenerator: 8];
 // myDist = [ExponentialDist create: [self getZone]
 // 		setGenerator: mySplitGen setVirtualGenerator: 8
 // 		setMean: 3.0 ];

  [self distDisplay7: myDist];
// -----
  myDist = [GammaDist createWithDefaults: [self getZone]];
  // myDist = [GammaDist create: [self getZone] setGenerator: mySimpleGen];
  // myDist = [GammaDist create: [self getZone] setGenerator: mySimpleGen
  // 		setAlpha: 3.0 setBeta: 1.5 ];
  // myDist = [GammaDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8];
  // myDist = [GammaDist create: [self getZone]
  // 		setGenerator: mySplitGen setVirtualGenerator: 8
  // 		setAlpha: 3.0 setBeta: 1.5 ];

  [self distDisplay7: myDist];
// -----
*/
/*
*/

  return self;
}

-buildActions {

  [super buildActions];

  return self;
}

-activateIn: (id) swarmContext {

  [super activateIn: swarmContext];

  return [self getSwarmActivity];
}

@end
