
void setup()
{
  size(2000, 1600);
  
  smooth();
  strokeWeight(1);
  background(0);
  fill(255);  
  noStroke();
  
  PVector[] pts = new PVector[500];
  PVector[] colors = new PVector[500];
  for (int i = 0; i < pts.length; i++)
  {
    pts[i] = new PVector(random(0, width), random(0, height));
    float intensity = random(200,255);
    colors[i] = new PVector(intensity, intensity, intensity);
  }
 
  for (int i = 0; i < width; i++)
  {
    for (int j = 0; j < height; j++)
    {
      float mindist = 999999999.0;
      PVector current = new PVector(i, j, 0);
      PVector min = new PVector(0,0,0);
      PVector intensity = new PVector(0,0,0);
      for (int k = 0; k < pts.length; k++)
      {
        float d = PVector.sub(current, pts[k]).mag();
        if (d < mindist)
        {
          mindist = d;
          min = pts[k];
          intensity = colors[k];
        }
      }
      
      color c = color(intensity.x, intensity.y, intensity.z, 255);
      set(i, j, c);    
      //println(red(c)+" "+blue(c)+" "+green(c)+" "+i+" "+j+" "+mindist);
      //break;
    }
  }
  
  for (int i = 0; i < pts.length; i++)
  {
    fill(255,255,255,100);
    ellipse(pts[i].x, pts[i].y, 4, 4);
  
    fill(255);
    ellipse(pts[i].x, pts[i].y, 1, 1);
  } 
  
  
}