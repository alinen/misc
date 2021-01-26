
void setup()
{
  //size(2000, 1600);
  size(800, 600);
  
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
    float intensity = random(0,100);
    if (floor(intensity) % 2 == 0)
    {
       colors[i] = new PVector(150+intensity, 27, 31);
    }
    else
    {
       colors[i] = new PVector(0, 20, 77+intensity);
    }
  }
 
  for (int i = 0; i < width; i++)
  {
    for (int j = 0; j < height; j++)
    {
      float mindist = 999999999.0;
      float mindist2 = mindist;
      PVector current = new PVector(i, j, 0);
      PVector min = new PVector(0,0,0);
      PVector intensity = new PVector(0,0,0);
      for (int k = 0; k < pts.length; k++)
      {
        float d = PVector.sub(current, pts[k]).mag();
        if (d < mindist)
        {
          mindist2 = mindist;
          mindist = d;
          min = pts[k];
          intensity = colors[k];
        }
      }
      
      float threshold = abs(mindist2 - mindist);
      if (threshold < 10 && threshold > 5.0)
      {
        float t = (threshold - 5.0)/(10.0 - 5.0);
        float r = floor(intensity.x * t + 255.0 * (1.0-t)); 
        float g = floor(intensity.y * t + 255.0 * (1.0-t)); 
        float b = floor(intensity.z * t + 255.0 * (1.0-t)); 
        
        intensity = new PVector(r,g,b);
      }
      else if (threshold < 5) 
      {
         intensity = new PVector(255,255,255);
      }      
            
      color c = color(intensity.x, intensity.y, intensity.z, 255);
      set(i, j, c);    
      //println(red(c)+" "+blue(c)+" "+green(c)+" "+i+" "+j+" "+mindist);
      //break;
    }
  }
  
  /*
  for (int i = 0; i < pts.length; i++)
  {
    fill(255,255,255,100);
    ellipse(pts[i].x, pts[i].y, 4, 4);
  
    fill(255);
    ellipse(pts[i].x, pts[i].y, 1, 1);
  } */
  
  
}