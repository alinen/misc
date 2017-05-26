
int numSpheres = 1000;
PImage img = null;
PVector[] pts = new PVector[numSpheres];
color[] colors = new color[numSpheres];
float theta = 0;
float spread = -1;
float startZ = -1;
float endZ = -1;
void setup()
{
  size(700, 700, OPENGL);
  
  img = loadImage("face.jpg");
  img.resize(width, height);

  smooth();
  strokeWeight(1);
  
  noStroke();
  lights();
  
  float startZ = -650;
  float z = startZ;
  float endZ = 100;
  float inc = (endZ - startZ)/5.0;
  int mod = floor(numSpheres/5.0);
  for (int i = 0; i < pts.length; i++)
  {
    pts[i] = new PVector(random(0, width), random(0, height), z);
    int jj = floor(pts[i].y+0.5);
    int ii = floor(pts[i].x+0.5);
    color c = img.get(ii, jj);
    colors[i] = c;
    if (i % 100 == 0) 
    {
      z += inc;
    }
  }
  spread = endZ - startZ;
  
  //ortho(-width/2, width/2, -height/2, height/2, -250, 250);
  //blendMode(ADD);
  background(0);

  theta = 0;//-1.1;

}

void draw()
{
  background(0);
  lights();
  scale(1.0, 1.0, 1.0);
  for (int i = 0; i < pts.length; i++)
  {
    fill(red(colors[i]), green(colors[i]), blue(colors[i]), 255);
    pushMatrix();
    translate(width/2, height/2, 0);
    rotateY(theta);
    translate(-width/2, -height/2, 0);
    translate(pts[i].x, pts[i].y, pts[i].z);
    
    float t = (pts[i].z+startZ)/spread;
    sphere(100*(1-t)+1);
    popMatrix();
  }   
  theta += 0.01;
}