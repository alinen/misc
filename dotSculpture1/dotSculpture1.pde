
int numSpheres = 1000;
PImage img = null;
PVector[] pts = new PVector[numSpheres];
color[] colors = new color[numSpheres];
float theta = 0;
void setup()
{
  size(700, 700, OPENGL);
  
  img = loadImage("nebula.jpg");
  img.resize(width, height);

  smooth();
  strokeWeight(1);
  
  noStroke();
  lights();
  
  for (int i = 0; i < pts.length; i++)
  {
    pts[i] = new PVector(random(0, width), random(0, height), random(0,500)-250);
    int jj = floor(pts[i].y+0.5);
    int ii = floor(pts[i].x+0.5);
    color c = img.get(ii, jj);
    colors[i] = c;
  }
  spread = endZ - startZ;
  
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
    fill(red(colors[i]), green(colors[i]), blue(colors[i]), 250);
    pushMatrix();
    translate(width/2, height/2, 0);
    rotateY(theta);
    translate(-width/2, -height/2, 0);
    translate(pts[i].x, pts[i].y, pts[i].z);
    
    sphere(10);
    popMatrix();
  }   
  theta += 0.01;
}
