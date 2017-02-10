
PImage img = null;
void setup()
{
  size(700, 700);
  
  img = loadImage("nebula.jpg");
  img.resize(width, height);

  smooth();
  strokeWeight(1);
  background(0);
  fill(255);  
  noStroke();
  
  image(img, 0, 0, width, height);

  PVector[] pts = new PVector[1000];
  for (int i = 0; i < pts.length; i++)
  {
    pts[i] = new PVector(random(0, width), random(0, height));
    
  }
  
  for (int i = 0; i < height; i++)
  {
    for (int j = 0; j < width; j++)
    {
      float mindist = 999999999.0;
      PVector current = new PVector(i, j, 0);
      PVector min = new PVector(0,0,0);
      for (int k = 0; k < pts.length; k++)
      {
        float d = PVector.sub(current, pts[k]).mag();
        if (d < mindist)
        {
          mindist = d;
          min = pts[k];
        }
      }
      
      int ii = floor(min.x+0.5);
      int jj = floor(min.y+0.5);
      color c = img.get(ii, jj);
      set(i, j, c);    
      //println(red(c)+" "+blue(c)+" "+green(c)+" "+ii+" "+jj+" "+mindist);
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