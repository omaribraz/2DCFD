class trail {
  PVector pos;
  PVector orientation;
  int strength = 255;
  Boid b;

  trail(PVector p, PVector o, Boid _b) {
    pos = p.copy();
    orientation = o.copy();
    orientation = orientation.normalize();
    b = _b;
    b.trailPop.add(this);
  }

  void update() {
    strength = strength-1;
    render();
    if (strength<1) {
     // b.trailPop.remove(this);
    }
  }

  void render() {

      //stroke(210, 50);

    //strokeWeight(2);
   // point(pos.x, pos.y);
  }
}