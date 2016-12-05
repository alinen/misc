class State
{
  public static final int NumParticles = 1500; // number of particles
  float mass; // mass
  PVector[] positions = new PVector[NumParticles];
  PVector[] velocities = new PVector[NumParticles];
  PVector[] vh = new PVector[NumParticles];
  PVector[] accelerations = new PVector[NumParticles];
  float[] rho = new float[NumParticles];
  boolean[] intersection = new boolean[NumParticles];
};