// Get all our imports out of the way
import heronarts.lx.*;
import heronarts.lx.audio.*;
import heronarts.lx.color.*;
import heronarts.lx.model.*;
import heronarts.lx.modulator.*;
import heronarts.lx.output.*;
import heronarts.lx.parameter.*;
import heronarts.lx.pattern.*;
import heronarts.lx.transition.*;
import heronarts.p2lx.*;
import heronarts.p2lx.ui.*;
import heronarts.p2lx.ui.control.*;
import ddf.minim.*;
import processing.opengl.*;
import heronarts.lx.output.*;

// Let's work in inches
final static int INCHES = 1;
final static int FEET = 12*INCHES;

// Top-level, we have a model and a P2LX instance
Model model;
P2LX lx;

MidiEngine midiEngine;

LXPattern[] patterns;

// Setup establishes the windowing and LX constructs
void setup() {
  size(800, 600, OPENGL);
  
  // Create the model, which describes where our light points are
  model = new Model();
  
  // Create the P2LX engine
  lx = new P2LX(this, model);
  
  // Set the patterns
  patterns = new LXPattern[] {
    new Rods(lx),
    new um3_lists(lx),
    new LayerDemoPattern(lx),
    new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx)),
    new AskewPlanes(lx),
    new ShiftingPlane(lx),
    new Pulley(lx),
    //new BouncyBalls(lx),
    new CrossSections(lx),
    //new CubeBounce(lx),
    new RainbowRods(lx),
    new RainbowInsanity(lx),
    new CrazyWaves(lx),
    new xwave(lx),
    new ywave(lx),
    new zwave(lx),
    new rainbowfade(lx),
    new DFC(lx),
    new rainbowfadeauto(lx),
    new MultiSine(lx),
    new SparkleTakeOver(lx),
    new SparkleHelix(lx),
    new um(lx),
    new um2(lx),
//    new um3(lx),
    //new um4(lx),
    new Stripes(lx),
    new SeeSaw(lx),
    new SweepPattern(lx),
  };
  lx.setPatterns(patterns);
  
  // Add UI elements
  lx.ui.addLayer(
    // A camera layer makes an OpenGL layer that we can easily 
    // pivot around with the mouse
    new UI3dContext(lx.ui) {
      protected void beforeDraw(UI ui, PGraphics pg) {
        // Let's add lighting and depth-testing to our 3-D simulation
        pointLight(0, 0, 40, model.cx, model.cy, -20*FEET);
        pointLight(0, 0, 50, model.cx, model.yMax + 10*FEET, model.cz);
        pointLight(0, 0, 20, model.cx, model.yMin - 10*FEET, model.cz);
        hint(ENABLE_DEPTH_TEST);
      }
      protected void afterDraw(UI ui, PGraphics pg) {
        // Turn off the lights and kill depth testing before the 2D layers
        noLights();
        hint(DISABLE_DEPTH_TEST);
      } 
    }
  
    // Let's look at the center of our model
    .setCenter(model.cx, model.cy, model.cz)
  
    // Let's position our eye some distance away
    .setRadius(16*FEET)
    
    // And look at it from a bit of an angle
    .setTheta(PI/24)
    .setPhi(PI/24)
    
    .setRotateVelocity(12*PI)
    .setRotateAcceleration(3*PI)
    
    // Let's add a point cloud of our animation points
    .addComponent(new UIPointCloud(lx, model).setPointWeight(3))
    
 
  );
  
  // A basic built-in 2-D control for a channel
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx.engine.getChannel(0), 4, 4));
  lx.ui.addLayer(new UIEngineControl(lx.ui, 4, 326));
  lx.ui.addLayer(new UIComponentsDemo(lx.ui, width-144, 4));

	// MIDI stuff (APC40)
  midiEngine = new MidiEngine(lx);

  buildOutputs();

}

void draw() {
  // Wipe the frame...
  background(#292929);
  // ...and everything else is handled by P2LX!
}

