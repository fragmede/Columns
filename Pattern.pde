/**
 * This file has a bunch of example patterns, each illustrating the key
 * concepts and tools of the LX framework.
 */
 
class LayerDemoPattern extends LXPattern {
  
  private final BasicParameter colorSpread = new BasicParameter("Clr", 0, 0, 100);
  private final BasicParameter stars = new BasicParameter("Stars", 0, 0, 100);
  private final BasicParameter saturation = new BasicParameter("sat", 100, 0, 100);
  
  public LayerDemoPattern(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(stars);
    addParameter(saturation);
    addLayer(new CircleLayer(lx));
    addLayer(new RodLayer(lx));
    for (int i = 0; i < 800; ++i) {
      addLayer(new StarLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    // The layers run automatically
  }
  
  private class CircleLayer extends LXLayer {
    
    private final SinLFO xPeriod = new SinLFO(1000, 3200, 1000); 
    private final SinLFO brightnessX = new SinLFO(model.xMin, model.xMax, xPeriod);
  
    private CircleLayer(LX lx) {
      super(lx);
      addModulator(xPeriod).start();
      addModulator(brightnessX).start();
    }
    
    public void run(double deltaMs) {
      // The layers run automatically
      float falloff = 100 / (FEET);
      for (LXPoint p : model.points) {
        float yWave = model.yRange/4 * sin(p.x / model.xRange * PI); 
        float distanceFromCenter = dist(p.x, p.y, model.cx, model.cy);
        float distanceFromBrightness = dist(p.x, abs(p.y - model.cy), brightnessX.getValuef(), yWave);
        colors[p.index] = LXColor.hsb(
          lx.getBaseHuef() + colorSpread.getValuef() * distanceFromCenter,
          100,
          max(0, 100 - falloff*distanceFromBrightness)
        );
      }
    }
  }
  
  private class RodLayer extends LXLayer {
    
    private final SinLFO zPeriod = new SinLFO(800, 1000, 2000);
    private final SinLFO zPos = new SinLFO(model.zMin, model.zMax, zPeriod);
    
    private RodLayer(LX lx) {
      super(lx);
      addModulator(zPeriod).start();
      addModulator(zPos).start();
    }
    
    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        float b = 100 - dist(p.x, p.y, model.cx, model.cy) - abs(p.z - zPos.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            lx.getBaseHuef() + p.z,
            0 + saturation.getValuef(),
            b
          ));
        }
      }
    }
  }
  
  private class StarLayer extends LXLayer {
    
    private final TriangleLFO maxBright = new TriangleLFO(0, stars, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000)); 
    
    private int index = 0;
    
    private StarLayer(LX lx) { 
      super(lx);
      addModulator(maxBright).start();
      addModulator(brightness).start();
      pickStar();
    }
    
    private void pickStar() {
      index = (int) random(0, model.size-1);
    }
    
    public void run(double deltaMs) {
      if (brightness.getValuef() <= 0) {
        pickStar();
      } else {
        addColor(index, LXColor.hsb(lx.getBaseHuef(), 50, brightness.getValuef()));
      }
    }
  }
}

//***************************ASkewPlanes*********************************************
//***************************ASkewPlanes*********************************************
//***************************ASkewPlanes*********************************************

class AskewPlanes extends LXPattern {
  
  class Plane {
    private final SinLFO a;
    private final SinLFO b;
    private final SinLFO c;
    float av = 1;
    float bv = 1;
    float cv = 1;
    float denom = 0.1;
    
    Plane(int i) {
      addModulator(a = new SinLFO(-1, 1, 4000 + 1029*i)).trigger();
      addModulator(b = new SinLFO(-1, 1, 11000 - 1104*i)).trigger();
      addModulator(c = new SinLFO(-50, 50, 4000 + 1000*i * ((i % 2 == 0) ? 1 : -1))).trigger();      
    }
    
    void run(double deltaMs) {
      av = a.getValuef();
      bv = b.getValuef();
      cv = c.getValuef();
      denom = sqrt(av*av + bv*bv);
    }
  }
    
  final Plane[] planes;
  final int NUM_PLANES = 3;
  
  AskewPlanes(LX lx) {
    super(lx);
    planes = new Plane[NUM_PLANES];
    for (int i = 0; i < planes.length; ++i) {
      planes[i] = new Plane(i);
    }
  }
  
  public void run(double deltaMs) {
    float huev = lx.getBaseHuef();
    
    // This is super fucking bizarre. But if this is a for loop, the framerate
    // tanks to like 30FPS, instead of 60. Call them manually and it works fine.
    // Doesn't make ANY sense... there must be some weird side effect going on
    // with the Processing internals perhaps?
//    for (Plane plane : planes) {
//      plane.run(deltaMs);
//    }
    planes[0].run(deltaMs);
    planes[1].run(deltaMs);
    planes[2].run(deltaMs);    
    
    for (LXPoint p : model.points) {
      float d = MAX_FLOAT;
      for (Plane plane : planes) {
        if (plane.denom != 0) {
          d = min(d, abs(plane.av*(p.x-model.cx) + plane.bv*(p.y-model.cy) + plane.cv) / plane.denom);
        }
      }
      colors[p.index] = lx.hsb(
        (huev + abs(p.x-model.cx)*.3 + p.y*.8) % 360,
        //max(0, 100 - .8*abs(p.x - model.cx)),
        random(40, 60),
        constrain(140 - 10.*d, 0, 100)
      );
    }
  }
}

//********************************ShiftingPlanes******************************************************************
//********************************ShiftingPlanes******************************************************************

class ShiftingPlane extends LXPattern {

  final SinLFO a = new SinLFO(-.2, .2, 5300);
  final SinLFO b = new SinLFO(1, -1, 13300);
  final SinLFO c = new SinLFO(-1.4, 1.4, 5700);
  final SinLFO d = new SinLFO(-10, 10, 9500);

  ShiftingPlane(LX lx) {
    super(lx);
    addModulator(a).trigger();
    addModulator(b).trigger();
    addModulator(c).trigger();
    addModulator(d).trigger();    
  }
  
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    float av = a.getValuef();
    float bv = b.getValuef();
    float cv = c.getValuef();
    float dv = d.getValuef();    
    float denom = sqrt(av*av + bv*bv + cv*cv);
    for (LXPoint p : model.points) {
      float d = abs(av*(p.x-model.cx) + bv*(p.y-model.cy) + cv*(p.z-model.cz) + dv) / denom;
      colors[p.index] = lx.hsb(
        (hv + abs(p.x-model.cx)*.6 + abs(p.y-model.cy)*.9 + abs(p.z - model.cz)) % 360,
        constrain(110 - d*6, 0, 100),
        constrain(130 - 7*d, 0, 100)
      );
    }
  }
}

//***********************************Pulley*******************************************************************
//***********************************Puley*******************************************************************
//***********************************Pulley*******************************************************************

class Pulley extends LXPattern {
  
  final int NUM_DIVISIONS = 16;
  private final Accelerator[] gravity = new Accelerator[NUM_DIVISIONS];
  private final Click[] delays = new Click[NUM_DIVISIONS];
  
  private final Click reset = new Click(2500);
  private boolean isRising = false;
  
  private BasicParameter sz = new BasicParameter("SIZE", 0.01);
  private BasicParameter beatAmount = new BasicParameter("BEAT", 0.25);
  
  Pulley(LX lx) {
    super(lx);
    for (int i = 0; i < NUM_DIVISIONS; ++i) {
      addModulator(gravity[i] = new Accelerator(0, 0, 0));
      addModulator(delays[i] = new Click(0));
    }
    addModulator(reset).start();
    addParameter(sz);
    addParameter(beatAmount);
    trigger();

  }
  
  private void trigger() {
    isRising = !isRising;
    int i = 0;
    for (Accelerator g : gravity) {
      if (isRising) {
        g.setSpeed(random(10, 20), 0).start();
      } else {
        g.setVelocity(0).setAcceleration(-200);
        delays[i].setDuration(random(0, 100)).trigger();
      }
      ++i;
    }
  }
  
  public void run(double deltaMs) {
    if (reset.click()) {
      trigger();
    }
        
    if (isRising) {
      // Fucking A, had to comment this all out because of that bizarre
      // Processing bug where some simple loop takes an absurd amount of
      // time, must be some pre-processor bug
//      for (Accelerator g : gravity) {
//        if (g.getValuef() > model.yMax) {
//          g.stop();
//        } else if (g.getValuef() > model.yMax*.55) {
//          if (g.getVelocityf() > 10) {
//            g.setAcceleration(-16);
//          } else {
//            g.setAcceleration(0);
//          }
//        }
//      }
    } else {
      int j = 0;
      for (Click d : delays) {
        if (d.click()) {
          gravity[j].start();
          d.stop();
        }
        ++j;
      }
      for (Accelerator g : gravity) {
        if (g.getValuef() < 0) {
          g.setValue(-g.getValuef());
          g.setVelocity(-g.getVelocityf() * random(0.64, 0.84));
        }
      }
    }

    
    float fPos = 1 - lx.tempo.rampf();
    if (fPos < .01) {
      fPos = .02 + 4 * (.2 - fPos);
    }
    float falloff = 100. / (3 + sz.getValuef() * 36 + fPos * beatAmount.getValuef()*48);
    for (LXPoint p : model.points) {
      int gi = (int) constrain((p.x - model.xMin) * NUM_DIVISIONS / (model.xMax - model.xMin), 0, NUM_DIVISIONS-1);
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + abs(p.x - model.cx)*.8 + p.y*.4) % 360,
        constrain(130 - p.y*.8, 0, 100),
        max(0, 100 - abs(p.y - gravity[gi].getValuef())*falloff)
      );
    }
  }
}

//***********************************Bouncyball*******************************************************************
//******************************************************************************************************
//***********************************Bouncyball*******************************************************************
class BouncyBalls extends LXPattern {
  
  static final int NUM_BALLS = 1;
  
  class BouncyBall {
       
    Accelerator yPos;
    TriangleLFO xPos = new TriangleLFO(0, model.xMax, random(8000, 19000));
    float zPos;
    
    BouncyBall(int i) {
      addModulator(xPos.setBasis(random(0, TWO_PI))).start();
      addModulator(yPos = new Accelerator(0, 0, 0));
      zPos = lerp(model.zMin, model.zMax, (i+2.) / (NUM_BALLS + 4.));
    }
    
    void bounce(float midiVel) {
      float v = 100 + 80*midiVel;
      yPos.setSpeed(v, getAccel(v, 60 / lx.tempo.bpmf())).start();
    }
    
    float getAccel(float v, float oneBeat) {
      return -2*v / oneBeat;
    }
    
    void run(double deltaMs) {
      float flrLevel = flr.getValuef() * model.xMax/2.;
      if (yPos.getValuef() < flrLevel) {
        if (yPos.getVelocity() < -50) {
          yPos.setValue(2*flrLevel-yPos.getValuef());
          float v = -yPos.getVelocityf() * bounce.getValuef();
          yPos.setSpeed(v, getAccel(v, 60 / lx.tempo.bpmf()));
        } else {
          yPos.setValue(flrLevel).stop();
        }
      }
      float falloff = 130.f / (12 + blobSize.getValuef() * 36);
      float xv = xPos.getValuef();
      float yv = yPos.getValuef();
      
      for (LXPoint p : model.points) {
        float d = sqrt((p.x-xv)*(p.x-xv) + (p.y-yv)*(p.y-yv) + .1*(p.z-zPos)*(p.z-zPos));
        float b = constrain(130 - falloff*d, 0, 100);
        if (b > 0) {
          blendColor(p.index, lx.hsb(
            (lx.getBaseHuef() + p.y*.5 + abs(model.cx - p.x) * .5) % 360,
            max(0, 100 - .45*(p.y - flrLevel)),
            b
          ), LXColor.Blend.ADD);
        }
      }
    }
  }
  
  final BouncyBall[] balls = new BouncyBall[NUM_BALLS];
  
  final BasicParameter bounce = new BasicParameter("BNC", .8);
  final BasicParameter flr = new BasicParameter("FLR", 0);
  final BasicParameter blobSize = new BasicParameter("SIZE", 0.5);
  
  BouncyBalls(LX lx) {
    super(lx);
    for (int i = 0; i < balls.length; ++i) {
      balls[i] = new BouncyBall(i);
    }
    addParameter(bounce);
    addParameter(flr);
    addParameter(blobSize);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
    for (BouncyBall b : balls) {
      b.run(deltaMs);
    }
  }
  }
//***********************************XC*******************************************************************
//******************************************************************************************************
//***********************************XC*******************************************************************
class CrossSections extends LXPattern {
  
  final SinLFO x = new SinLFO(0, model.xMax, 5000);
  final SinLFO y = new SinLFO(0, model.yMax, 6000);
  final SinLFO z = new SinLFO(0, model.zMax, 7000);
  
  final BasicParameter xw = new BasicParameter("XWID", 0.3);
  final BasicParameter yw = new BasicParameter("YWID", 0.3);
  final BasicParameter zw = new BasicParameter("ZWID", 0.3);  
  final BasicParameter xr = new BasicParameter("XRAT", 0.7);
  final BasicParameter yr = new BasicParameter("YRAT", 0.6);
  final BasicParameter zr = new BasicParameter("ZRAT", 0.5);
  final BasicParameter xl = new BasicParameter("XLEV", 1);
  final BasicParameter yl = new BasicParameter("YLEV", 1);
  final BasicParameter zl = new BasicParameter("ZLEV", 0.5);

  
  CrossSections(LX lx) {
    super(lx);
    addModulator(x).trigger();
    addModulator(y).trigger();
    addModulator(z).trigger();
    addParams();
  }
  
  protected void addParams() {
    addParameter(xr);
    addParameter(yr);
    addParameter(zr);    
    addParameter(xw);
    addParameter(xl);
    addParameter(yl);
    addParameter(zl);
    addParameter(yw);    
    addParameter(zw);
  }
  
  void onParameterChanged(LXParameter p) {
    if (p == xr) {
      x.setDuration(10000 - 8800*p.getValuef());
    } else if (p == yr) {
      y.setDuration(10000 - 9000*p.getValuef());
    } else if (p == zr) {
      z.setDuration(10000 - 9000*p.getValuef());
    }
  }
  
  float xv, yv, zv;
  
  protected void updateXYZVals() {
    xv = x.getValuef();
    yv = y.getValuef();
    zv = z.getValuef();    
  }

  public void run(double deltaMs) {
    updateXYZVals();
    
    float xlv = 100*xl.getValuef();
    float ylv = 100*yl.getValuef();
    float zlv = 100*zl.getValuef();
    
    float xwv = 100. / (10 + 40*xw.getValuef());
    float ywv = 100. / (10 + 40*yw.getValuef());
    float zwv = 100. / (10 + 40*zw.getValuef());
    
    for (LXPoint p : model.points) {
      color c = 0;
      c = PImage.blendColor(c, lx.hsb(
      (lx.getBaseHuef() + p.x/10 + p.y/3) % 360, 
      constrain(140 - 1.1*abs(p.x - model.xMax/2.), 0, 100)*0.6, 
      max(0, xlv - xwv*abs(p.x - xv))
        ), ADD);
      c = PImage.blendColor(c, lx.hsb(
      (lx.getBaseHuef() + 80 + p.y/10) % 360, 
      constrain(140 - 2.2*abs(p.y - model.yMax/2.), 0, 100)*0.6, 
      max(0, ylv - ywv*abs(p.y - yv))
        ), ADD); 
      c = PImage.blendColor(c, lx.hsb(
      (lx.getBaseHuef() + 160 + p.z / 10 + p.y/2) % 360, 
      constrain(140 - 2.2*abs(p.z - model.zMax/2.), 0, 100)*0.6, 
      max(0, zlv - zwv*abs(p.z - zv))
        ), ADD); 
      colors[p.index] = c;
    }
  }
}

//***********************************CubeBoune*******************************************************************
//******************************************************************************************************
//***********************************CubeBounce*******************************************************************

class CubeBounce extends LXPattern {

  private final BasicParameter cvel = new BasicParameter("cvel", 1, 1/2, 10);
  
  
  class BouncingCube {
    float bcx;
    float bcy;
    float bcz;
    float edgelengthxz;
    float edgelengthy;
    float hue;
    float bcvelx;
    float bcvely;
    float bcvelz;
    float rhue;
  
    
  BouncingCube() {
    edgelengthxz = FEET*2;
    edgelengthy = FEET*1.3;
    bcx = 3;
    bcy = random(1, 15);
    bcz = 3;
    bcvelx = .25;
    bcvely = .25;
    bcvelz = .25;
    hue = random(100);
    rhue = second();
    
  }
  } 
  
  private BouncingCube bouncingcube;
  public CubeBounce(LX lx)
  {
    super(lx);
    bouncingcube = new BouncingCube();
    addParameter(cvel);
  }
  public void run(double deltaMs) {
    
  
    for(LXPoint p : model.points) {
      colors[p.index] = 0;
    }
   
   if (bouncingcube.bcx > model.xMax || bouncingcube.bcx < model.xMin) {
    bouncingcube.bcvelx = -bouncingcube.bcvelx;
    bouncingcube.hue = random(255);
   } 
   if (bouncingcube.bcy > model.yMax || bouncingcube.bcx < model.yMin) {
    bouncingcube.bcvely = -bouncingcube.bcvely;
    bouncingcube.hue = random(255);
   }
    if (bouncingcube.bcz > model.zMax || bouncingcube.bcx < model.zMin) {
    bouncingcube.bcvelz = -bouncingcube.bcvelz;
    bouncingcube.hue = random(255);
   }
   
   
   bouncingcube.bcx = bouncingcube.bcx + bouncingcube.bcvelx * cvel.getValuef();
   bouncingcube.bcy = bouncingcube.bcy + bouncingcube.bcvely * cvel.getValuef();
   bouncingcube.bcz = bouncingcube.bcz + bouncingcube.bcvelz * cvel.getValuef();
 
   for (LXPoint p : model.points) {
     if (p.x > bouncingcube.bcx - bouncingcube.edgelengthxz && p.x < bouncingcube.bcx + bouncingcube.edgelengthxz &&
        p.y > bouncingcube.bcy - bouncingcube.edgelengthy && p.y < bouncingcube.bcy + bouncingcube.edgelengthy &&
       p.z > bouncingcube.bcz - bouncingcube.edgelengthxz && p.z < bouncingcube.bcz + bouncingcube.edgelengthxz) 
   {
     //colors[p.index] = lx.hsb(bouncingcube.hue, 100, 100);
     //colors[p.index] = lx.hsb(
        //(bouncingcube.hue + abs(p.x - model.cx)*1 + p.y*.4) % 360,
        //constrain(130 - p.y*.8, 0, 100),
        //max(0, 100));
        colors[p.index] = lx.hsb(86, 55, max(0, 1000 - abs(p.y - bouncingcube.bcy*4)));
   }
   }
}
}

//***********************************RF*******************************************************************
//******************************************************************************************************
//***********************************RF*******************************************************************

class RainbowRods extends LXPattern {
  
  class Rod {
    float rodx;
    float rodz;
    float rody;
    float rhue;
    float ravel;
    float rbvel;
    float rcvel;
    float rdvel;
    float revel;
    float rodheight;
    float rodsize;
    
  Rod() {
    rodx = random (model.xMin, model.xMax);
    rody = 1;
    rodz = random (model.xMin, model.xMax);
    rhue = millis();
    ravel = random (.3 , 1.1);
    rbvel = random (.3 , 1.1);
    rcvel = random (.3 , 1.1);
    rdvel = random (.3 , 1.1);
    revel = random (.3 , 1.1);
    rodheight = model.yMax;
    rodsize = 7;
    
  }
  }
  
  private Rod roda;
  private Rod rodb;
  private Rod rodc;
  private Rod rodd;
  private Rod rode;
  public RainbowRods(LX lx)
  {
    super(lx);
    roda = new Rod();
    rodb = new Rod();
    rodc = new Rod();
    rodd = new Rod();
    rode = new Rod();
  }
  public void run(double deltaMx) {
    
    for(LXPoint p : model.points) {
      colors[p.index] = 0;
    }
    
    if(roda.rody > model.yMax + roda.rodheight/2) {
      roda.rody = -roda.rodheight/2;
      roda.rodx = random (model.xMin, model.xMax);
      roda.rodz = random (model.xMin, model.xMax);
      
    }
      
      if(rodb.rody > model.yMax + rodb.rodheight/2) {
      rodb.rody = -rodb.rodheight/2;
      rodb.rodx = random (model.xMin, model.xMax);
      rodb.rodz = random (model.xMin, model.xMax);
      
      
    }
     
      
      if(rodc.rody > model.yMax + rodc.rodheight/2) {
      rodc.rody = -rodc.rodheight/2;
      rodc.rodx = random (model.xMin, model.xMax);
      rodc.rodz = random (model.xMin, model.xMax);
      
      
    }
    
    if(rodd.rody > model.yMax + rodd.rodheight/2) {
      rodd.rody = -rodd.rodheight/2;
      rodd.rodx = random (model.xMin, model.xMax);
      rodd.rodz = random (model.xMin, model.xMax);
      
    }
    
    if(rode.rody > model.yMax + rode.rodheight/2) {
      rode.rody = -rode.rodheight/2;
      rode.rodx = random (model.xMin, model.xMax);
      rode.rodz = random (model.xMin, model.xMax);
      
    }
    
    roda.rody = roda.rody + roda.ravel;
    rodb.rody = rodb.rody + rodb.rbvel;
    rodc.rody = rodc.rody + rodc.rcvel;
    rodd.rody = rodd.rody + rodd.rdvel;
    rode.rody = rode.rody + rode.revel;
    
    for(LXPoint p : model.points) {
      if(p.x > roda.rodx - roda.rodsize && p.x < roda.rodx + roda.rodsize &&
      p.z > roda.rodz - roda.rodsize && p.z < roda.rodz + roda.rodsize &&
      p.y > roda.rody - roda.rodheight/2 && p.y < roda.rody + roda.rodheight/2)
      {
        colors[p.index] = lx.hsb((millis() * 0.05), 90, 89);
        
      }
    }
    
        
        for(LXPoint p : model.points) {
      if(p.x > rodb.rodx - rodb.rodsize && p.x < rodb.rodx + rodb.rodsize &&
      p.z > rodb.rodz - rodb.rodsize && p.z < rodb.rodz + rodb.rodsize &&
      p.y > rodb.rody - rodb.rodheight/2 && p.y < rodb.rody + rodb.rodheight/2)
      {
       colors[p.index] = lx.hsb((millis() * 0.1 + p.y * 2), 70, 89);
        
      }
        }
      for(LXPoint p : model.points) {
      if(p.x > rodc.rodx - rodc.rodsize && p.x < rodc.rodx + rodc.rodsize &&
      p.z > rodc.rodz - rodc.rodsize && p.z < rodc.rodz + rodc.rodsize &&
      p.y > rodc.rody - rodc.rodheight/2 && p.y < rodc.rody + rodc.rodheight/2)
      {
       colors[p.index] = lx.hsb((millis() * 0.2 + p.y * 2), 70, 89);
      }
      }
      
      for(LXPoint p : model.points) {
      if(p.x > rodd.rodx - rodd.rodsize && p.x < rodd.rodx + rodd.rodsize &&
      p.z > rodd.rodz - rodd.rodsize && p.z < rodd.rodz + rodd.rodsize &&
      p.y > rodd.rody - rodd.rodheight/2 && p.y < rodd.rody + rodd.rodheight/2)
      {
       colors[p.index] = lx.hsb((millis() * 0.4 + p.y * 2), 70, 89);
      }
      }
      
      for(LXPoint p : model.points) {
      if(p.x > rode.rodx - rode.rodsize && p.x < rode.rodx + rode.rodsize &&
      p.z > rode.rodz - rode.rodsize && p.z < rode.rodz + rode.rodsize &&
      p.y > rode.rody - rode.rodheight/2 && p.y < rode.rody + rode.rodheight/2)
      {
       colors[p.index] = lx.hsb((millis() * 0.03 + p.y * 2), 70, 89);
      }
      }
      
        }
        }
        
//--------------------------------xwave------------------------------------------------------------

class ywave extends LXPattern {
  
  private final SinLFO yPos = new SinLFO(0, model.yMax, 2000);
  
  public ywave(LX lx) {
    super(lx);
    addModulator(yPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (LXPoint p : model.points) {
       // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 100 - abs(p.y - yPos.getValuef()) * 3);
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}
//--------------------------------xwave------------------------------------------------------------

class xwave extends LXPattern {
  
  private final SinLFO xPos = new SinLFO(0, model.xMax, 2000);
  
  public xwave(LX lx) {
    super(lx);
    addModulator(xPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (LXPoint p : model.points) {
       // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 100 - abs(p.x - xPos.getValuef()) * 3);
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}
//--------------------------------zwave------------------------------------------------------------


class zwave extends LXPattern {
  
  private final SinLFO zPos = new SinLFO(0, model.zMax, 2000);
  
  public zwave(LX lx) {
    super(lx);
    addModulator(zPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (LXPoint p : model.points) {
       // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 100 - abs(p.z - zPos.getValuef()) * 3);
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}
      
  //--------------------------------RainbowInsanity------------------------------------------------------------
  
  class RainbowInsanity extends LXPattern {
    
    private final SinLFO yPos = new SinLFO(0, model.yMax, 1000);
     private final SinLFO brightnessY = new SinLFO(model.yMin, model.yMax, yPos);
    
    public RainbowInsanity(LX lx) {
    super(lx);
    addModulator(yPos).trigger();
  }
  public void run(double deltaMs) {
    float falloff = 10 / (FEET);
    
    for (LXPoint p : model.points) {
      float yWave = model.yRange*0.9 * sin(p.y / model.yRange * PI); 
        float distanceFromCenter = dist(p.x, p.y, model.cx, model.cy);
        float distanceFromBrightness = dist(p.y, abs(p.y - model.cy), brightnessY.getValuef(), yWave);
        colors[p.index] = LXColor.hsb(
          lx.getBaseHuef()/2 * distanceFromCenter*0.4,
          65,
          max(0, 100 - falloff*distanceFromBrightness)
          );
    }
  }
}

//--------------------------------crazywaves------------------------------------------------------------

class CrazyWaves extends LXPattern {
  
  private final SinLFO yPos = new SinLFO(0, model.yMax, 8000);
  private final BasicParameter thickness = new BasicParameter("thick", 2.5, 1, 5);
  
  public CrazyWaves(LX lx) {
    super(lx);
    addModulator(yPos).trigger();
    addParameter(thickness);
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (LXPoint p : model.points) {
       // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 1000 - abs(p.y - yPos.getValuef()) * thickness.getValuef());
      colors[p.index] = lx.hsb(hv, 60, bv);
    }
  }
}
//--------------------------------Rainbowfade------------------------------------------------------------

class rainbowfade extends LXPattern {
  
  public rainbowfade(LX lx) {
    super(lx);
  }
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = lx.hsb(millis() * 0.1 - p.y + p.x + p.z * 2, 30,80);
    }
  }
}
//--------------------------------DFC------------------------------------------------------------

class DFC extends LXPattern {
  private final BasicParameter thickness = new BasicParameter("thick", 6, 1, 20);
  private final BasicParameter speed = new BasicParameter("speed", 0.05, 0.05, .5);
  
  public DFC(LX lx) {
    super(lx);
    addParameter(thickness);
    addParameter(speed);
  }
  public void run(double deltaMs) {
    for (LXPoint p: model.points) {
      float distancefromcenter = dist(p.x, p.y, p.z, model.cx, model.cy, model.cz);
      colors[p.index] = lx.hsb(millis() * speed.getValuef() - distancefromcenter * thickness.getValuef(), 30, 100 - distancefromcenter*2);
      
    }
  }
}


        

