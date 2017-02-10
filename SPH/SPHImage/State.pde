class State
{
  public static final int NumParticles = 1000; // number of particles
  float mass; // mass
  PVector[] positions = new PVector[NumParticles];
  PVector[] velocities = new PVector[NumParticles];
  PVector[] vh = new PVector[NumParticles];
  PVector[] accelerations = new PVector[NumParticles];
  color[] colors = new color[NumParticles];
  float[] rho = new float[NumParticles];
  boolean[] intersection = new boolean[NumParticles];
};