
private class MyFluidData implements Fluid.FluidData {

  // update() is called during the fluid-simulation update step.
  @Override
    public void update(Fluid fluid) {

    float px, py, vx, vy, radius, vscale, r, g, b, intensity, temperature;

  for (int i = 0; i < flock.boids.size(); i++) {
    Boid t = (Boid) flock.boids.get(i);

      vscale = 15;
      px     = t.location.x;
      py     = t.location.y;
      vx     = t.velocity.x;
      vy     = t.velocity.y;
      radius = 10;
      intensity = 1.0f;
      temperature = -5f;

      fluid.addVelocity   (px, py, radius, vx, vy);


        fluid.addTemperature(px, py, radius, temperature);

        radius = 20;
        fluid.addDensity    (px, py, radius, 0, 0, 0, intensity);
        radius = 25;
        fluid.addDensity    (px, py, radius, 0, 0.4f, 1, intensity);
      
  }

  }
}