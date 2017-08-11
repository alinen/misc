
PImage img = null;

float blurFilter[];
void createFilter(int size, float var)
{
  blurFilter = new float[size];
  float center = (((float) size) - 1.0)/2.0;
  float C = 1.0/(var * sqrt(2*PI));
  for (int i = 0; i < size; i++)
  {
    float du = ((float)i) - center;
    float radius = -0.5 * du * du / var;
    float e = exp(radius);
    float wgt = C*e;
    blurFilter[i] = wgt;
  }
}

void drawFilter(float maxHeight, float barWidth)
{
  float sum = 0;
  for (int i = 0; i < blurFilter.length; i++)
  {
    sum += blurFilter[i];
  }  
  
  float x = 0;
  float y = maxHeight;
  fill(255,0,0);
  stroke(0);
  for (int i = 0; i < blurFilter.length; i++)
  {
    rect(x,y,barWidth, maxHeight * blurFilter[i]/sum);
    x += barWidth*1.01;
  }
}

void blurV()
{

}

void blurH()
{
  int center = (blurFilter.length - 1)/2;
  for (int i = 0; i < height; i++)
  {
    for (int j = center; j < width-center; j++)
    {
      for (int k = 0; k < blurFilter.length; k++)
      {
        
      }
      color c = img.get(i, j);
      set(i, j, c);    
      //println(red(c)+" "+blue(c)+" "+green(c)+" "+ii+" "+jj+" "+mindist);
      //break;
    }
  }
}

void setup()
{
  size(700, 700);
  
  smooth();
  strokeWeight(1);
  background(0);

  noStroke();
  for (int i = 0; i < 1000; i++)
  {
    fill(255);
    ellipse(random(0, width), random(0, height), 2, 2);
  }
  
  stroke(255);
  PVector[] pts = new PVector[500];
  for (int i = 0; i < pts.length; i++)
  {
    pts[i] = new PVector(random(0, width), random(0, height));    
    fill(255);
    ellipse(pts[i].x, pts[i].y, 5, 5);
  }
  
  // create lines to closest dots with some probability
  for (int i = 0; i < pts.length; i++)
  {
    float mindist = Float.MAX_VALUE;
    float minx = 0;
    float miny = 0;
    for (int j = 0; j < pts.length; j++)
    {      
        if (i == j) continue;
        float d = PVector.sub(pts[i], pts[j]).mag();
        if (d < mindist)
        {
          mindist = d;
          minx = pts[j].x;
          miny = pts[j].y;
        }
    }
      float r = noise(i);
      if (r > 0.1 && mindist < Float.MAX_VALUE) line(pts[i].x, pts[i].y, minx, miny);  
      //println(mindist);   
  }
  

  
  //createFilter(11, 0.5);
  //blurH();
  //drawFilter(100,10);
}