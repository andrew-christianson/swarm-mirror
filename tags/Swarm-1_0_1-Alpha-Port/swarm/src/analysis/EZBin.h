// Swarm library. Copyright (C) 1996 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <swarmobject/MessageProbe.h>

// EZBin object: used to generate histograms.

@interface EZBin : MessageProbe {
  int graphics ;
  id aHisto ;

  int fileOutput ;
  id anOutFile ;

  char *theTitle ;
  char *xLabel ;
  char *yLabel ;

  int *distribution ;
  double *locations ;
  double *cachedLimits ;
  double min, max ;
  int clean ;
  int binNum ;
  int count ;
  int outliers ;
  id collection;

  double minval,maxval,average,average2,std ;
}

-setTitle: (char *) aTitle ; 
-setAxisLabelsX: (char *) xl Y: (char *) yl ;

-setGraphics: (int) state ;
-setFileOutput: (int) state ;

-setBinNum: (int) theBinNum ;
-setLowerBound: (double) theMin ;
-setUpperBound: (double) theMax ;
-setCollection: (id) aCollection;

-reset;
-update;
-output ;

-(int *)getDistribution ;

-(int) getCount;
-(int) getOutliers ;
-(int) getBinNum ;
-(double) getUpperBound ;
-(double) getLowerBound ;

-(double) getMin ;
-(double) getMax ;
-(double) getAverage ;
-(double) getStd ;
@end