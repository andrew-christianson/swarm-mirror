package swarm;
import swarm.random.*;
import swarm.simtoolsgui.*;
import swarm.defobj.*;
import swarm.activity.*;
import swarm.objectbase.*;

public class SwarmEnvironment {
  static {
    System.out.println ("Trying to load lib!\n");
    try {
      System.loadLibrary ("javaswarm");
    }
    catch (Exception e) {
      System.err.println ("Exception caught: " + e.getMessage ());
    } 
    System.out.println ("Lib loaded!\n");
  }
  public native void initSwarm (String args[]);
  public native int getCurrentTime ();
  public native SwarmImpl getCurrentSwarm ();
  public native ScheduleImpl getCurrentSchedule ();
  public native SwarmActivityImpl getCurrentSwarmActivity ();
  public native ScheduleActivityImpl getCurrentScheduleActivity();
  public native ActivityImpl getCurrentOwnerActivity ();
  public native ActionImpl getCurrentAction ();
  public native ActivityImpl getCurrentActivity();

  public native Object createProbeDisplay (Object anOjbect);
  public native Object createCompleteProbeDisplay (Object anObject);
  public native Object createArchivedProbeDisplay (Object anObject);
  public native Object createArchivedCompleteProbeDisplay (Object anObject);
  public native Object setWindowGeometryRecordName (Object theWidget);
  public native Object setComponentWindowGeometryRecordNameFor (Object obj,
							      Object widget);
  public native Object setComponentWindowGeometryRecordName (Object widget);

  
  public SymbolImpl ControlStateRunning, ControlStateStopped,
    ControlStateStepping, ControlStateQuit, ControlStateNextTime;
  public ProbeLibraryImpl probeLibrary;
  public ProbeDisplayManagerImpl probeDisplayManager;

  public ZoneImpl globalZone;
  public UniformIntegerDistImpl uniformIntRand;
  public UniformDoubleDistImpl uniformDblRand;
  public SwarmEnvironment (String args[]) {
    initSwarm (args);

  }
}


