// Java Heatbugs application. Copyright � 1999-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular
// purpose.  See file COPYING for details and terms of copying.

// All added comments copyright 2001 Timothy Howe. All rights reserved. 

import swarm.Globals;
import swarm.space.Grid2d;
import swarm.space.Grid2dImpl;
import swarm.gui.Raster;

import java.awt.Point;

/**
See HeatbugModelSwarm for an overview of the heatbugs application.

<p>
A Heatbug is an agent in a 2-dimensional world. A Heatbug has the following
behavior:

 <dir>
 A Heatbug has an ideal temperature (which is a property of the individual
 Heatbug), and a color that indicates the Heatbug's ideal 
 temperature (more green for cool-loving Heatbugs, more yellow for 
 warmth-loving Heatbugs).
 </dir>

 <dir>
 A Heatbug can sense the temperature of the cells in its 9-cell neighborhood.
 </dir>

 <dir>
 A Heatbug has an unhappiness, which is equal to the difference between the
 Heatbug's ideal temperature and the temperature of the cell where it sits.
 </dir>

 <dir>
 With an arbitrary probability (which is a property of the individual
 Heatbug), a Heatbug will move to a randomly-chosen empty cell in its 9-cell
 neighborhood.
 </dir>

 <dir>
 If a Heatbug does not move in the arbitrary fashion described in
 the previous paragraph, it will move to an empty cell in
 its 9-cell neighborhood whose temperature is closest to
 its ideal temperature. If there is more than once such
 cell, it will choose at random among the cells with that closest-to-ideal
 temperature.
 </dir>

 <dir>
 If a Heatbug does not move in the rational fashion described in
 the previous paragraph, it will make 10 attempts to move to a 
 randomly-chosen empty cell in its immediate neighborhood. 
 <dir>

 </dir>
 In all cases a Heatbug move only if its unhappiness is non-zero.
 </dir>

 <dir>
 Two or more Heatbugs may not occupy a given cell simultaneously. However,
 for simpler code, we do allow some collisions at initialization time -- the 
 Heatbugs quickly separate themselves.
 </dir>

 <dir>
 A Heatbug produces heat (the amount is a property of the individual Heatbug),
 but it deposits the heat at the cell where it was sitting, not at the cell
 it is going to.
 </dir>

*/
public class Heatbug
{
    public int x, y;
    public double unhappiness;
    public double getUnhappiness () { return unhappiness; }
    public int idealTemperature;
    public int getIdealTemperature () { return idealTemperature; }
    public Object setIdealTemperature (int idealTemperature)
      { this.idealTemperature = idealTemperature; return this; }
    // The amount of heat I produce:
    public int outputHeat;
    public Object setOutputHeat (int outputHeat)
      { outputHeat = outputHeat; return this; }
    // The chance that I will move arbitrarily:
    public double randomMoveProbability;
    public Object setRandomMoveProbability (double randomMoveProbability)
    { this.randomMoveProbability = randomMoveProbability; return this; }
    // The 2-dimensional world I move in:
    private Grid2d _world;
    // The heat of each cell of the 2-dimensional world:
    private HeatSpace _heatSpace;
   // My personal index to the ColorMap defined in HeatbugModelSwarm:
    private byte _colorIndex;
    public void setColorIndex (byte colorIndex)
    { _colorIndex = colorIndex; }
    // The model I belong to:
    private HeatbugModelSwarm _model;
    // My index in the Heatbug list:
    private int _heatbugIndex;

    private int _printDiagnostics = 0;
    public void setPrintDiagnostics (int printDiagostics)
    { _printDiagnostics = printDiagostics; }

public Heatbug 
 (Grid2d world, 
  HeatSpace heatSpace, 
  HeatbugModelSwarm model,
  int heatbugIndex,
  int printDiagnostics
 )
{
    _world = world;
    _heatSpace = heatSpace;
    _model = model;
    _heatbugIndex = heatbugIndex;
    _printDiagnostics = printDiagnostics;

    if (_world == null)
        System.err.println ("Heatbug was created without a world");

    if (_heatSpace == null)
        System.err.println ("Heatbug was created without a heatSpace");

} /// constructor

/**
This method does not check to see whether the target cell is already occupied.
*/
public Object setX$Y (int inX, int inY)
{
    x = inX;
    y = inY;
    _world.putObject$atX$Y (this, x, y);
    return this;
}

/**
This method defines what the Heatbug does whenever the Schedule triggers it. 

<p>
The method is synchronized, which means the compiler will not let it be 
multi-threaded, which means it cannot be parallelized. It is synchronized 
because to avoid collisions, the Heatbugs must decide one at a time which 
cell to move to. 

<p>
There may be other methods in this simulation that should be synchronized. 

*/
public synchronized void heatbugStep ()
{
    int heatHere;
    int newX, newY;

    // Get the heat where I am sitting:
    heatHere = _heatSpace.getValueAtX$Y (x, y);

    // Update my current unhappiness:
    unhappiness
     = (double) Math.abs (idealTemperature - heatHere) 
     / (_model.getActivity ().getScheduleActivity ().getCurrentTime () + 1);
     /* ... The divisor is an attempt to neutralize the effect of the 
        increasing heat of the HeatSpace. Without the divisor, Heatbugs would 
        keep getting happier as the heat increases, even if they're immobile
        or they move only randomly. Our real interest is in the happiness of 
        Heatbugs that is due to their motion. 

        Todo: We should bring the evaporation rate into the computation. 
        Diffusion should be irrelevant. Discarding of heat greater than 
        MAx_HEAT in _heatSpace.addHeat() might be a problem. 

        We're missing something here, because with "evaporation" rate == 1,
        and the Heatbugs immobilized with the -i option, they still get
        happier as time goes by. 
    */

    if (unhappiness != 0 && ! _model.getImmobile ())
    {

        double uDR = Globals.env.uniformDblRand.getDoubleWithMin$withMax (0.0, 1.0);
        if (uDR < randomMoveProbability)
        {
            if (_printDiagnostics >= 100)
                System.out.print ("Moving randomly ... ");
            // Pick a random cell within the 9-cell neighborhood, applying
            // geographic wrap-around:
            newX =
             (x + Globals.env.uniformIntRand.getIntegerWithMin$withMax (-1, 1)
              + _world.getSizeX ()
             ) % _world.getSizeX ();
            newY =
             (y + Globals.env.uniformIntRand.getIntegerWithMin$withMax (-1, 1)
              + _world.getSizeY ()
             ) % _world.getSizeY ();
        } else
        {
            if (_printDiagnostics >= 100)
                System.out.print ("Moving rationally ... ");
            Point scratchPoint = new Point (x, y);
            // Ask the HeatSpace for a cell in the 9-cell neighborhood
            // with the closest-to-ideal temperature: 
            _heatSpace.findExtremeType$X$Y
             ((heatHere < idealTemperature ? HeatSpace.HOT : HeatSpace.COLD),
              scratchPoint,   // scratchPoint is an inout parameter
              _world
             );
            newX = scratchPoint.x;
            newY = scratchPoint.y;
        }
        // ... Whether it chose randomly or rationally, a Heatbug may have
        // chosen the cell it is already at. If it did, the choice is about
        // to be rejected, since the code below checks to see whether the cell
        // is already occupied, without asking which Heatbug is occupying it:
        if (_world.getObjectAtX$Y (newX, newY) != null)
        {
            int tries = 0;
            int location, xm1, xp1, ym1, yp1;
            // 10 is an arbitrary choice for the number of tries; it is
            // *not* implied by the number of cells in the neighborhood:
            while ((_world.getObjectAtX$Y (newX, newY) != null) && 
                   (tries < 10)
                  )
            {
                // Choose randomly among the 8 cells in the neighborhood
                location = Globals.env.uniformIntRand.getIntegerWithMin$withMax (1,8);
                xm1 = (x + _world.getSizeX () - 1) % _world.getSizeX ();
                xp1 = (x + 1) % _world.getSizeX ();
                ym1 = (y + _world.getSizeY () - 1) % _world.getSizeY ();
                yp1 = (y + 1) % _world.getSizeY ();
                switch (location)
                {
                case 1:  
                    newX = xm1; newY = ym1;   // NW
                break;  
                case 2:
                    newX = x ; newY = ym1;    // N
                break;  
                case 3:
                    newX = xp1 ; newY = ym1;  // NE
                break;  
                case 4:
                    newX = xm1 ; newY = y;    // W
                break;  
                case 5:
                    newX = xp1 ; newY = y;    // E
                break;  
                case 6:
                    newX = xm1 ; newY = yp1;  // SW
                break;  
                case 7:
                    newX = x ; newY = yp1;    // S
                break;  
                case 8:
                    newX = xp1 ; newY = yp1;  // SE
                default:
                break;
                }
                tries++;
            }
            if (tries == 10)
            {
                if (_printDiagnostics >= 100)
                    System.out.println ("no, staying put ... ");
                newX = x;
                newY = y;
            }
            else
            {
                if (_printDiagnostics >= 100)
                    System.out.println ("no, desperately ... ");
            }
        }

        // Deposit heat at my old location; move to my new location. We
        // never subtract heat -- so even if the Heatbugs don't move, they
        // may still become happier:
        _heatSpace.addHeat (outputHeat, x, y);
        _world.putObject$atX$Y (null, x, y);
        x = newX;
        y = newY;
        _world.putObject$atX$Y (this, x, y);

    } /// if unhappiness != 0
    else
    {
        if (_printDiagnostics >= 100)
        {
            System.out.println ("Too happy to move ... ");
        }
        _heatSpace.addHeat (outputHeat, x, y);
    }

    if (_printDiagnostics >= 100)
        System.out.println ("Heatbug " + this);

} /// heatbugStep()

public Object drawSelfOn (Raster raster)
{
    raster.drawPointX$Y$Color (x, y, _colorIndex);
    return this;
}

/**
The Java compiler will invoke this method whenever we use a Heatbug where the
compiler is expecting a String. That gives us an easy way to print diagnostics;
for example, System.out.println ("I initialized Heatbug " + heatbug + ".");.
*/
public String toString ()
{
    return _heatbugIndex + " at (" + x + "," + y + "), heat " + _heatSpace.getValueAtX$Y (x, y);
}

} /// class Heatbug
