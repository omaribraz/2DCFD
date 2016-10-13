import com.thomasdiewald.pixelflow.java.Fluid;
import com.thomasdiewald.pixelflow.java.PixelFlow;

import processing.core.*;
import processing.opengl.PGraphics2D;

import controlP5.Accordion;
import controlP5.Button;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;

Flock flock;


int viewport_w = 1080;
int viewport_h = 800;
int fluidgrid_scale = 1;

int BACKGROUND_COLOR = 0;

PImage img0;

boolean UPDATE_FLUID = true;

boolean DISPLAY_FLUID_TEXTURES  = true;
boolean DISPLAY_FLUID_VECTORS   = !true;
boolean DISPLAY_PARTICLES       = !true;

int     DISPLAY_fluid_texture_mode = 0;

public Fluid fluid;
PGraphics2D pg_fluid;
PGraphics2D pg_obstacles;


public void setup() {
  size(1080, 800, P2D);
  smooth(2);
  this.img0 = loadImage("drone.png");


  PixelFlow context = new PixelFlow(this);
  context.print();
  context.printGL();

  fluid = new Fluid(context, viewport_w, viewport_h, fluidgrid_scale);

  fluid.param.dissipation_density     = 0.99f;
  fluid.param.dissipation_velocity    = 0.92f;
  fluid.param.dissipation_temperature = 0.5f;
  fluid.param.vorticity               = 0.10f;

  MyFluidData cb_fluid_data = new MyFluidData();
  fluid.addCallback_FluiData(cb_fluid_data);


  pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_fluid.smooth(4);

  pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_obstacles.noSmooth();
  pg_obstacles.beginDraw();
  pg_obstacles.clear();
  
  pg_obstacles.rectMode(CENTER);
  pg_obstacles.noStroke();
  pg_obstacles.fill(80);
  randomSeed(0);
  for (int i = 0; i < 80; i++) {
    float px = random(width);
    float py = random(height);
    float sx = random(15, 60);
    float sy = random(15, 60);
    pg_obstacles.rect(px, py, sx, sy);
  }
  // border-obstacle
  pg_obstacles.rectMode(CORNER);
  pg_obstacles.strokeWeight(20);
  pg_obstacles.stroke(64);
  pg_obstacles.noFill();
  pg_obstacles.rect(0, 0, pg_obstacles.width, pg_obstacles.height);
  pg_obstacles.endDraw();

  fluid.addObstacles(pg_obstacles);




  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 5; i++) {
    flock.addBoid(new Boid(random(1080/2-450, 1080/2+450), random(720/2-350, 720/2+350)));
  }
  frameRate(60);
}

public void draw() {
  background(0);

  strokeWeight(1);
  flock.run();





  //for (int i = 0; i < flock.boids.size(); i++) {
  //  Boid t = (Boid) flock.boids.get(i); 

  //  if (t.trailPop != null) {
  //    for (int j = 0; j < t.trailPop.size(); j++) {
  //      trail k = (trail) t.trailPop.get(j); 
  //      //pg_obstacles.fill(255);
  //      //pg_obstacles.ellipse(k.pos.x,k.pos.y,30,30);
  //     // k.update();
  //    }
  //  }
  //}

  //fluid.addObstacles(pg_obstacles);


  if (UPDATE_FLUID) {
    fluid.update();
  }

  pg_fluid.beginDraw();
  pg_fluid.background(BACKGROUND_COLOR);
  pg_fluid.endDraw();

  if (DISPLAY_FLUID_TEXTURES) {
    // render: density (0), temperature (1), pressure (2), velocity (3)
    fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
  }

  if (DISPLAY_FLUID_VECTORS) {
    // render: velocity vector field
    fluid.renderFluidVectors(pg_fluid, 250);
  }

  if (DISPLAY_PARTICLES) {
  }




  image(pg_fluid, 0, 0);
  image(pg_obstacles, 0, 0);

  for (int i = 0; i < flock.boids.size(); i++) {
    Boid t = (Boid) flock.boids.get(i); 
    t.render();
  }






  if(frameCount%5==0){
    saveFrame("frame" + frameCount + ".jpg");
  }
}





// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
}




public void keyReleased() {
  if (key == 'p') fluid_togglePause(); // pause / unpause simulation
  if (key == '+') fluid_resizeUp();    // increase fluid-grid resolution
  if (key == '-') fluid_resizeDown();  // decrease fluid-grid resolution
  if (key == 'r') fluid_reset();       // restart simulation

  if (key == '1') DISPLAY_fluid_texture_mode = 0; // density
  if (key == '2') DISPLAY_fluid_texture_mode = 1; // temperature
  if (key == '3') DISPLAY_fluid_texture_mode = 2; // pressure
  if (key == '4') DISPLAY_fluid_texture_mode = 3; // velocity

  if (key == 'q') DISPLAY_FLUID_TEXTURES = !DISPLAY_FLUID_TEXTURES;
  if (key == 'w') DISPLAY_FLUID_VECTORS  = !DISPLAY_FLUID_VECTORS;
  if (key == 'e') DISPLAY_PARTICLES      = !DISPLAY_PARTICLES;
}

public void fluid_resizeUp() {
  fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
}
public void fluid_resizeDown() {
  fluid.resize(width, height, ++fluidgrid_scale);
}
public void fluid_reset() {
  //    particle_system.reset();
  fluid.reset();
}
public void fluid_togglePause() {
  UPDATE_FLUID = !UPDATE_FLUID;
}
public void setDisplayMode(int val) {
  DISPLAY_fluid_texture_mode = val;
  DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
}
public void setDisplayVelocityVectors(int val) {
  DISPLAY_FLUID_VECTORS = val != -1;
}
public void setDisplayParticles(int val) {
  DISPLAY_PARTICLES = val != -1;
}