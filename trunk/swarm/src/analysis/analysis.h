// Swarm library. Copyright (C) 1996-1999 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

//S: Analysis tools

//D: This is the library where tools primarily related to analysis tasks,
//D: reside. This includes tools which simplify the task of graphing
//D: values or displaying distributions as well as more specific
//D: measurement tools (such as Average, Entropy). 

#import <objectbase.h>
#import <simtoolsgui.h> // GUIComposite
#import <gui.h> // GraphElement

@protocol Averager <MessageProbe, CREATABLE>
//S: Averages together data, gives the data to whomever asks.

//D: Averager objects read a value (via a MessageProbe) from a
//D: collection (typically a list) of objects and collect statistics over them.

CREATING
//M: Sets the collection of objects that will be probed.
- setCollection: aCollection;

- createEnd;

USING
//M: The update method runs through the collection calling the selector on 
//M: each object.
- update;

//M: The getAverage method averages the values the averager collects. The total
//M: and count are read out of the object to compute the average.
- (double)getAverage;

//M: The getTotal method sums the values the averager collects. The value is 
//M: read out of the object, not computed everytime it is asked for.
- (double)getTotal;

//M: The getMin method returns the minimum value the averager collects. The 
//M: value is read out of the object, not computed everytime it is asked for.
- (double)getMin;

//M: The getCount method returns the number of values the averager collects. 
- (unsigned)getCount;
@end

@protocol Entropy <MessageProbe, CREATABLE>
//S: Computes entropy via a MessageProbe.

//D: Entropy objects read probabilities (via a MessageProbe) from a
//D: collection of objects and calculate the entropy of the
//D: underlying distribution.

CREATING
//M: The setCollection method sets the collection of objects that will be 
//M: probed.
- setCollection: aCollection;

- createEnd;

USING
//M: The update method polls the collection and updates the entropy.
//M: This method should be scheduled prior to collecting the data using
//M: getEntropy.
- update;

//M: The getEntropy method returns the calculated Entropy. The entropy value
//M: is read out of the object, not computed everytime it is requested.
- (double)getEntropy;
@end

@protocol EZBin <SwarmObject, GUIComposite, CREATABLE>
//S: An easy to use histogram interface.

//D: This class allows the user to easily histogram data generated by a
//D: collection of objects. In addition the class will generate some
//D: standard statistics over the resulting dataset.

CREATING
+ createBegin: (id <Zone>)aZone;

//M: The setGraphics method sets the state of the display. Set the state to 0 
//M: if a graphical display of the graph is not required. 
//M: The default state is 1 meaning that by default the data appears
//M: graphically in a window. 
- setGraphics: (BOOL)state;

//M: The setCollection method sets the collection of target objects which will 
//M: be requested to generate the dataset for the histogram.
- setCollection: aCollection;

//M: The setProbedSelector method sets the selector that will be applied to
//M: the objects in the specified collection in order to generate the dataset 
//M: (inherited from MessageProbe.)
- setProbedSelector: (SEL)aSel;

//M: The setFileOutput method sets the state of file I/O.  Set the state to 1 
//M: if data for the sequences is to be sent to a file.  The default state is 0
//M: meaning that by default no file I/O is carried out by the EZBin class.
- setFileOutput: (BOOL)state;

//M: The setTitle method uses a title string to label a graph window in the 
//M: graphical version of EZBin.  The label appears at the top of the graph 
//M: window. (Only relevant if the state of setGraphics is set to 1.)
- setTitle: (const char *)title;

//M: The setFileName method sets the name used for disk file data output.
//M: (Only relevant if the state of seFileOutput is set to 1.)
//M: If not set, the filename defaults to be the same as the graph title.
- setFileName: (const char *)fileName;

//M: The setAxisLabels:X:Y method sets the horizontal and vertical labels on 
//M: the histogram in the graphical version of EZBin. (Only relevant if the 
//M: state of setGraphics is set to 1.)
- setAxisLabelsX: (const char *)xl Y: (const char *)yl;

//M: The setMonoColorBars method specifies whether all bars should be shown
//M: in a single color (blue). The default is differently colored bars.
- setMonoColorBars: (BOOL)mcb;

//M: The setBinCount method sets the number of bins the histogram will have.
- setBinCount: (unsigned)theBinCount;

//M: The setLowerBound method sets the inclusive lower bound on the
//M: histogram range. 
- setLowerBound: (double)theMin;

//M: The setUpperBound method sets the non-inclusive upper bound on the
//M: histogram range.
- setUpperBound: (double)theMax;

//M: Set a custom vector of colors for the histogram bars
- setColors: (const char * const *)colors count: (unsigned)nc;

- createEnd;

USING

//M: Sets the number of significant figures shown for major-tick labels.
- setPrecision: (unsigned)precision;

//M: The reset method resets the histogram.
- reset;

//M: The update method polls the collection of objects and adds the data to the
//M: final data set. It is possible to poll the same collection of objects 
//M: repeatedly, thus increasing the amount of data included in the final 
//M: dataset, before generating output.
- update;

//M: The ouputGraph method causes the graphical display to be updated with the
//M: information extracted by the previous call to update. If setGraphics==0,
//M: nothing is done.
- outputGraph;

//M: The outputToFile method causes the number of entries per bin to be sent to
//M: the output file, using the data extracted by the previous call to update.
//M: If setFileOutput==0, nothing is done.
- outputToFile;

//M: The output: method combines the actions of -outputGraph and -outputToFile.
//M: If graph updates and file output need to happen at different frequencies,
//M: schedule calls to -outputGraph and -outputToFile instead of -output.
- output;

//M: The getDistribution method returns an array of integers containing the 
//M: number of entries which landed in each bin of the histogram.
- (unsigned *)getDistribution;

//M: The getCount method gets the number of entries which landed within the 
//M: bounds of the histogram.
- (unsigned)getCount;

//M: The getOutliers method gets the number of entries which landed out of the 
//M: bounds of the histogram.  Pressing the "o" key on the graphical 
//M: representation of the histogram will display this value both as an integer
//M: and as a percentage of the total number of attempted entries.
- (unsigned)getOutliers;

//M: The getBinCount method gets the number of bins in the histogram.
- (unsigned)getBinCount;

//M: The getBinColorCount method gets the number of distinct bin colors 
//M: allocated (by default, or by the user).
- (unsigned)getBinColorCount;

//M: The getLowerBound method gets the lower bound on the histogram range.
- (double)getLowerBound;

//M: The getUpperBound method gets the upper bound on the histogram range.
- (double)getUpperBound;

//M: The getMin method gets the minimum value in the dataset.
- (double)getMin;

//M: The getMax method gets the maximum value in the dataset.
- (double)getMax;

//M: The getAverage method gets the average value in the dataset. The 
//M: value is read out of the object, not computed everytime it is asked for.
- (double)getAverage;

//M: The getStd method gets the standard deviation in the dataset. The 
//M: value is read out of the object, not computed everytime it is asked for.
- (double)getStd;

//M: Return the histogram widget.
- (id <Histogram>)getHistogram;

//M: Return the title string.
- (const char *)getTitle;

//M: Return the filename string.
- (const char *)getFileName;
@end

@protocol EZDistribution <EZBin, CREATABLE>
//S: An EZBin that treats data as a distribution.

//D: This is a subclass of EZBin which normalizes the data and treats
//D: it as a distribution.
//D: This means that in addition to the statistics it can calculate by virtue
//D: of being a subclass of EZBin, it can also calculate the entropy of the
//D: distribution as well as return the probabilities associated with the
//D: individual bins.
CREATING
- createEnd;

USING
//M: The update method polls the bins and updates the entropy of the 
//M: distribution as well as the probabilities associated with the individual 
//M: bins.
- update;

//M: The output method causes the graphical display to be updated with the 
//M: information extracted by the previous call to update.  When file I/O is 
//M: enabled (the state of setFileOutput is set to 1), the probability
//M: associated with each bin is sent to the output file. When the graphical 
//M: display is enabled (the state of setGraphics is set to 1), the histogram 
//M: will be drawn.
- output;

//M: The getProbabilities method returns an array of doubles representing
//M: the probability of every bin in the distribution.
- (double *)getProbabilities;

//M: The getEntropy method returns the entropy of the distribution as
//M: calculated in the previous call to update.
- (double)getEntropy;
@end

@protocol EZSequence <SwarmObject, RETURNABLE>
//S:

//D:
CREATING
SETTING
USING
@end

@protocol EZGraph <SwarmObject, GUIComposite, CREATABLE>
//S: A class for easily create graphs.

//D: This class allows the user to easily create graphs of various
//D: quantities in the model s/he is investigating. 
//D: The user first creates the EZGraph, and then creates "Sequences"; 
//D: (lines) which will appear in the graph. 
//D: The sequences are generated based on data provided by a 
//D: single object or a collection of target objects, in reponse to a
//D: specified selector.
//D: One of the features of the EZGraph is that it will automatically
//D: generate average, total, min, max and count sequences without the
//D: user having to mess with Averagers amd other low-level classes.

CREATING

//M: Convenience method for creating `graphical' EZGraph instances
+ create: (id <Zone>)aZone setTitle: (const char *)aTitle setAxisLabelsX: (const char *)xl Y: (const char *)yl;

//M: Convenience method for creating a non-graphical EZGraph, the
//M: filename is generated from the sequence name
+ create: (id <Zone>)aZone setFileOutput: (BOOL)fileOutputFlag;

//M: Convenience method for creating a non-graphical EZGraph, in this case, the
//M: filename is explicitly set by the user
+ create: (id <Zone>)aZone setFileName: (const char *)aFileName;

//M: The setGraphics method sets the state of the display. Set the state to 0 
//M: if a graphical display of the graph is not required.
//M: The default state is 1 meaning that by default the data appears
//M: graphically in a window. 
- setGraphics: (BOOL)state;

//M: The setFileOutput method sets the state of file I/O.  Set the state to 1 
//M: if data for the sequences is to be sent to a file.  The default state is 0
//M: meaning that by default no file I/O is carried out by the EZGraph class.
- setFileOutput: (BOOL)state;

//M: The setFileName method sets the name used for disk file data output.
//M: (Only relevant if the state of setFileOutput is set to 1.)
//M: The name set here is prepended to the names of each data sequence.
//M: If file name is NOT set, with this method, the file name for the sequence
//M: will default simply to the sequence name.
- setFileName: (const char *)aFileName;

//M: The setTitle method uses a title string to label a graph window in the 
//M: graphical version of EZGraph.  The label appears at the top of the graph 
//M: window. (Only relevant if the state of setGraphics is set to 1.)
- setTitle: (const char *)aTitle;

//M: The setAxisLabels:X:Y method sets the horizontal and vertical labels on 
//M: the histogram in the graphical version of EZGraph. (Only relevant if the 
//M: state of setGraphics is set to 1.)
- setAxisLabelsX: (const char *)xl Y:(const char *)yl;

//M: Set a custom vector of colors for the graph lines
- setColors: (const char * const *)colors count: (unsigned)nc;

- createEnd;

USING
//M: Fix the range of X values on the graph between some range.
- setRangesXMin: (double)xmin Max: (double)xmax;

//M: Fix the range of Y values on the graph between some range.
- setRangesYMin: (double)ymin Max: (double)ymax;

//M: Whether to autoscale every timestep or instead to jump scale.
- setScaleModeX: (BOOL)xs Y: (BOOL)ys;

//M: The getGraph method lets the user access the graph generated internally
//M: by the EZGraph. (Only relevant if the state of setGraphics is set to 1.)
- (id <Graph>)getGraph;

//M: The createSequence method creates a sequence in the EZGraph based on
//M: the return value provided by the object anObj when sent the selector
//M: aSel.  If file I/O is enabled, then the data will be sent to a file with
//M: the name aName, otherwise the aName argument is simply used as the
//M: legend for the graph element generated by EZGraph.
//M: The method returns an id which can be used later with -dropSequence.
- createSequence: (const char *)aName
    withFeedFrom: anObj
     andSelector: (SEL)aSel;

//M: The createAverageSequence method takes a collection of objects and 
//M: generates a sequence based on the average over the responses of the
//M: entire object set (as opposed to a single object as in createSequence)
//M: The method returns an id which can be used later with -dropSequence.
- createAverageSequence: (const char *)aName 
           withFeedFrom: aCollection 
            andSelector: (SEL)aSel;

//M: The createTotalSequence method takes a collection of objects and 
//M: generates a sequence based on the sum over the responses of the
//M: entire object set (as opposed to a single object as in createSequence)
//M: The method returns an id which can be used later with -dropSequence.
- createTotalSequence: (const char *)aName
         withFeedFrom: aCollection 
          andSelector: (SEL)aSel;

//M: The createMinSequence method takes a collection of objects and 
//M: generates a sequence based on the minimum over the responses of the
//M: entire object set (as opposed to a single object as in createSequence)
//M: The method returns an id which can be used later with -dropSequence.
- createMinSequence: (const char *)aName 
       withFeedFrom: aCollection 
        andSelector: (SEL)aSel;

//M: The createMaxSequence method takes a collection of objects and 
//M: generates a sequence based on the maximums over the responses of the
//M: entire object set (as opposed to a single object as in createSequence)
//M: The method returns an id which can be used later with -dropSequence.
- createMaxSequence: (const char *)aName
       withFeedFrom: aCollection 
        andSelector: (SEL)aSel;

//M: The createCountSequence method takes a collection of objects and 
//M: generates a sequence based on the count over the responses of the
//M: entire object set (as opposed to a single object as in createSequence)
//M: The method returns an id which can be used later with -dropSequence.
- createCountSequence: (const char *)aName
         withFeedFrom: aCollection 
          andSelector: (SEL) aSel;

//M: The dropSequence method drops a data sequence (line on the graph),
//M: e.g. because the source object no longer exists. The aSeq parameter
//M: should be an id previously returned by one of the createSequence:
//M: methods. If the drop is successful, the method returns aSeq,
//M: otherwise it returns nil.
- dropSequence: aSeq;  

//M: Return the title string.
- (const char *)getTitle;

//M: Return the file name prefix string.
- (const char *)getFileName;

//M: the -update method causes the underlying sequences to get the next set
//M: of data values. If a sequence has a single object attached rather
//M: than an Averager, nothing is done.
- update;

//M: the outputGraph method updates the graph with the data obtained from
//M: the last call to -update. If setGraphics==0, nothing is done.
- outputGraph;

//M: the outputToFile method sends to the disk file data obtained from the
//M: last call to -update. If setFileOutput==0, nothing is done.
- outputToFile;

//M: The step method combines -update, -outputGraph and -outputToFile.
//M: If you want file output to occur at a different frequency than graph
//M: updates, schedule those methods separately instead of using -step.
- step;

@end

@protocol ActiveGraph <MessageProbe, CREATABLE>
//S: Provides a continuous data feed between Swarm and the GUI.

//D: An active graph object is the glue between a MessageProbe (for reading
//D: data) and a Graph GraphElement. ActiveGraphs are created and told
//D: where to get data from and send it to, and then are scheduled to
//D: actually do graphic functions. This class is used by EZGraph, and we
//D: expect to see less direct usage of it by end-users as more analysis
//D: tools (such as EZGraph) internalize its functionality.
USING
//M: Sets the graph element used to draw on.
- setElement: ge;

//M: Sets the object that will be probed for data.
- setDataFeed: d;

//M: Fires the probe, reads the value from the object, and draws it
//M: on the graph element. The X value is implicitly the current
//M: simulation time. Y is the value read. 
- step;
@end

@protocol ActiveOutFile <MessageProbe, CREATABLE>
//S: An object that actively updates its file stream when updated.

//D: This is the file I/O equivalent of ActiveGraph: it takes an OutFile 
//D: object, a target (datafeed) object, and a selector, which it uses to
//D: extract data from the object and send it to the file. 
USING
//M: The setFileObject: method sets the file object to which the data will be
//M: sent.
- setFileObject: aFileObj;

//M: The setDataFeed: method sets the object that will be probed for data.
- setDataFeed: d;

//M: The step method fires the probe, reads the value from the object, and 
//M: sends the value to the file.
- step;
@end

@protocol FunctionGraph <SwarmObject, CREATABLE>
//S: A widget for drawing a function over a range of one variable.
 
//D: The FunctionGraph class is like the ActiveGraph except that instead of
//D: plotting values versus time it plots them versus some specified range
//D: on the x-axis.  Also, instead of plotting one value on each step (as
//D: you would with time), FunctionGraph does a complete sampling whenever
//D: the `graph' method is called.  That is, it graphs f(x) = y for all x
//D: in [minX, maxX] where x = minX + n * stepS ize.

//D: The user specifies stuff like minX, maxX, the number of steps between
//D: minX and maxX to sample at and a method selector that is a wrapper for
//D: the equation being graphed. The method selector must be in a
//D: particular format: (BOOL) f: (double *) x : (double *) y If the method
//D: returns FALSE then that x value is skipped, otherwise it is assummed
//D: that y = f(x) and that value is plotted.

CREATING
+ createBegin: (id <Zone>)aZone;
- createEnd;

//M: Set the GraphElement to use for plotting.
- setElement: (id <GraphElement>)graphElement;

//M: Set the target to send the function method.
- setDataFeed: feed;

//M: Set the function method.
- setFunctionSelector: (SEL)aSel;

//M: If true, raise a warning if the function method failed to compute a value.
- setArithmeticWarn: (BOOL)state;

//M: Set the range and resolution of X values at which to compute values.
- setXMin: (double)minx Max: (double)maxx Resolution: (unsigned)steps;

//M: Set the range and step size of X values at which to compute values.
- setXMin: (double)minx Max: (double)maxx StepSize: (double)size;

//M: Set the frequency at which to clear the graph element.
- setResetFrequency: (unsigned)freq;

USING
//M: Draw the graph with the current contents of the graph element.
- graph;
@end

@class Averager;
@class Entropy;
@class EZBin;
@class EZDistribution;
@class EZGraph;
@class EZSequence;
@class ActiveGraph;
@class ActiveOutFile;
@class FunctionGraph;
