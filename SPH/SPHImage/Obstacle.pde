class Obstacle
{
  public PVector a;
  public PVector b;
  public float r = 10;
  public Obstacle(PVector _a, PVector _b)
  {
    a = _a;
    b = _b;
  }
  
  public Obstacle(float ax, float ay, float bx, float by)
  {
    a = new PVector(ax, ay, 0);
    b = new PVector(bx, by, 0);
  }
};