// The Boid class

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  ArrayList trailPop;

  Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    location = new PVector(x, y);
    r = 7.0;
    maxspeed = 2;
    maxforce = 0.07;
    trailPop = new ArrayList();
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    if (frameCount%10==0) trail();
    update();
    borders();
    //render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    //PVector stig = seektrail(trailPop);
    // Arbitrarily weight these forces
    sep.mult(1.5);
    //stig.mult(0.5);
    ali.mult(0.04);
    coh.mult(0.01);
    // Add the force vectors to acceleration
    applyForce(sep);
    //applyForce(stig);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void trail() {
    trail tr = new trail(location.copy(), velocity.copy(), this);
    trailPop.add(tr);
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    // float theta = velocity.heading() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    fill(200, 100);
    stroke(255);
    //pushMatrix();
    float fg = viewport_h - location.y;
    float fh = fg;
    if (fg<0) {
      fh = fg*(-1);
    }
    image(img0,location.x-30, fh-45, 60,60);
    //rotate(theta);
    // beginShape(TRIANGLES);
    // vertex(0, -r*2);
    // vertex(-r, r*2);
    // vertex(r, r*2);
    // endShape();
    // popMatrix();
  }

  // Wraparound
  void borders() {
    if (location.x < 5*r) velocity = velocity.mult(-1);
    if (location.y < 5*r) velocity.mult(-1);
    if (location.x > width-(5*r)) velocity.mult(-1);
    if (location.y > height-(5*r)) velocity.mult(-1);

    if (location.x < 5*r) location.x = 5*r;
    if (location.y < 5*r) location.y = 5*r;
    if (location.x > width-(5*r)) location.x = width-(5*r);
    if (location.y > height-(5*r)) location.y = height-(5*r);
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  PVector seektrail(ArrayList tPop) {
    float neighbordist = 90;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;

    for (int i = 0; i < tPop.size(); i++) {
      trail t = (trail) tPop.get(i); 
      float distance = PVector.dist(location, t.pos);
      if ((distance < neighbordist)&&(inView(t.pos, 60))) {
        sum.add(t.pos); // Add location
        count++;
        float theta2 = velocity.copy().heading() + radians(90);
        fill(255, 255, 0, 2);
        noStroke();
        pushMatrix();
        translate(location.x, location.y);
        rotate(theta2);
        beginShape(TRIANGLES);
        vertex(0, -r*2);
        vertex(-r*5, -90);
        vertex(r*5, -90);
        endShape();
        popMatrix();
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    }    
    return sum;
  }

  boolean inView(PVector target, float angle) {
    boolean resultBool; 
    PVector vec = target.copy().sub(location.copy());
    float result = PVector.angleBetween(velocity.copy(), vec);
    result = degrees(result);
    if (result < angle) {
      resultBool = true;
    } else { 
      resultBool = false;
    }
    return resultBool;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } else {
      return new PVector(0, 0);
    }
  }
}