State state = new State();
System system = new System();
float maxdensity = 0;

boolean paused = true;

Obstacle newObstacle;
boolean dragNdrop = false;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

PVector fluidOffset = new PVector(0,0,0);
PImage img;

void setup() 
{
  size(512, 512);
  smooth();
  strokeWeight(1);
  background(0);
  fill(255);

  img = loadImage("../assets/Hs-2009-25-e-full_jpg.jpg");
  img.resize(width, height);
  init_fluid();
  
  state.positions[0].y = 241;
  state.velocities[0].y = -20;
  damp_reflect(0, new Obstacle(0,height, width, height));
} //<>//

void init_fluid()
{
  int numcols = floor(width / (2.2 * system.r));
  println(width+" "+numcols);
  float margin = system.r * 2.2;
  for (int i = 0; i < State.NumParticles; i++)
  {
     int cellj = i % numcols;
     int celli = floor(i/numcols);
     state.positions[i] = new PVector(system.r+cellj*margin, system.r+celli*margin, 0);
     state.positions[i].x += fluidOffset.x;
     state.positions[i].y += fluidOffset.y;
     state.velocities[i] = new PVector(0,0,0);
     state.accelerations[i] = new PVector(0,0,0);
     
     int imgi = floor(state.positions[i].x+0.5);
     int imgj = floor(state.positions[i].y+0.5);
     color c = img.get(imgi, imgj);
     state.colors[i] = c;
     state.vh[i] = new PVector(0,0,0);
     //println (state.positions[i]);
  }
  
  normalize_mass();
  compute_accel();
  leapfrog_start();
}

void compute_density()
{
   maxdensity = 0;
   float h = system.h;
   float h2 = h*h;
   float h8 = ( h2*h2 )*( h2*h2 );
   float C = 4 * state.mass / 3.14 / h8;
   for (int i = 0; i < State.NumParticles; i++) state.rho[i] = 0;
   for (int i = 0; i < State.NumParticles; ++i) 
   {
      state.rho[i] += 4 * state.mass / 3.14 / h2;
      for (int j = i+1; j < State.NumParticles; ++j) 
      {
         float dx = state.positions[i].x - state.positions[j].x;
         float dy = state.positions[i].y - state.positions[j].y;
         float r2 = dx*dx + dy*dy;
         float z = h2-r2;
         if (z > 0) 
         {
            float rho_ij = C*z*z*z;
            state.rho[i] += rho_ij;
            state.rho[j] += rho_ij;
         }
      }
   }  
   
   for (int i = 0; i < State.NumParticles; i++) maxdensity = max(maxdensity, state.rho[i]);
   //println(maxdensity);
}

void normalize_mass()
{
   state.mass = 1;
   compute_density();
   float rho0 = system.rho0;
   float rho2s = 0;
   float rhos = 0;
   for (int i = 0; i < State.NumParticles; ++i) 
   {
      rho2s += (state.rho[i])*(state.rho[i]);
      rhos += state.rho[i];
   }
   state.mass *= ( rho0*rhos / rho2s );
}

void compute_accel()
{
  // Unpack basic parameters
  float h = system.h;
  float rho0 = system.rho0;
  float k = system.k;
  float mu = system.mu;
  float mass = state.mass;
  float h2 = h*h;

  // Compute density and color
  compute_density();

  // Start with gravity and surface forces
  for (int i = 0; i < State.NumParticles; ++i) 
  {
    state.accelerations[i].x = 0;
    state.accelerations[i].y = system.g;
    for (int j = 0; j < obstacles.size(); j++)
    {
      boolean b = capsule_intersect(state.positions[i], state.velocities[i], obstacles.get(j));
      //if (b)
      {
        // compute repellent force
        PVector force = capsule_force(state.positions[i], state.velocities[i], obstacles.get(j));
        state.accelerations[i].x -= force.x;   //attract
        state.accelerations[i].y -= force.y;       // attract 
      }
    }    
  }
  
  // Constants for interaction term
  float C0 = mass / 3.14 / ( (h2)*(h2) );
  float Cp = 15*k;
  float Cv = -40*mu;
  
  // Now compute interaction forces
  for (int i = 0; i < State.NumParticles; ++i) 
  {
    float rhoi = state.rho[i];
    for (int j = i+1; j < State.NumParticles; ++j) 
    {
      float dx = state.positions[i].x-state.positions[j].x;
      float dy = state.positions[i].y-state.positions[j].y;
      float r2 = dx*dx + dy*dy;      
      if (r2 < h2) 
      {
        float rhoj = state.rho[j];
        float q = sqrt(r2)/h;
        float u = 1-q;
        float w0 = C0 * u/rhoi/rhoj;
        float wp = w0 * Cp * (rhoi+rhoj-2*rho0) * u/q;
        float wv = w0 * Cv;
        float dvx = state.velocities[i].x - state.velocities[j].x;
        float dvy = state.velocities[i].y - state.velocities[j].y;
        
        state.accelerations[i].x += (wp*dx + wv*dvx);
        state.accelerations[i].y += (wp*dy + wv*dvy);
        
        state.accelerations[j].x -= (wp*dx + wv*dvx);
        state.accelerations[j].y -= (wp*dy + wv*dvy);
      }
    }
    //println("here "+state.accelerations[i]);
  }
  //println("here "+state.accelerations[0]);
}

void leapfrog_step()
{
  float maxacc = 100;
  for (int i = 0; i < State.NumParticles; ++i)
  {
    float mag = sqrt(state.accelerations[i].x*state.accelerations[i].x + 
        state.accelerations[i].y*state.accelerations[i].y);
      
    if (mag > maxacc) 
    {
      state.accelerations[i].x = state.accelerations[i].x/mag * maxacc;
      state.accelerations[i].y = state.accelerations[i].y/mag * maxacc;
    }
    state.vh[i].x += state.accelerations[i].x * system.dt;
    state.vh[i].y += state.accelerations[i].y * system.dt;
  }
  for (int i = 0; i < State.NumParticles; ++i)
  {
    state.velocities[i].x = state.vh[i].x + state.accelerations[i].x * system.dt / 2;
    state.velocities[i].y = state.vh[i].y + state.accelerations[i].y * system.dt / 2;
  }
  for (int i = 0; i < State.NumParticles; ++i)
  {
    state.positions[i].x += state.vh[i].x * system.dt;
    state.positions[i].y += state.vh[i].y * system.dt;
  }
  reflect_bc();
}

void leapfrog_start()
{
  for (int i = 0; i < State.NumParticles; ++i)
  {
    state.vh[i].x = state.velocities[i].x + state.accelerations[i].x * system.dt / 2;
    state.vh[i].y = state.velocities[i].y + state.accelerations[i].y * system.dt / 2;
  }
  for (int i = 0; i < State.NumParticles; ++i)
  {
    state.velocities[i].x += state.accelerations[i].x * system.dt;
    state.velocities[i].y += state.accelerations[i].y * system.dt;
  }
  for (int i = 0; i < State.NumParticles; ++i)
  {
    state.positions[i].x += system.dt * state.vh[i].x;
    state.positions[i].y += system.dt * state.vh[i].y;
  }
  reflect_bc();
}

PVector capsule_force(PVector p, PVector v, Obstacle obs)
{
  PVector ba = new PVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y, 0);
  PVector pa = new PVector(p.x-obs.a.x, p.y-obs.a.y, 0);
  PVector pb = new PVector(p.x-obs.b.x, p.y-obs.b.y, 0);
  
  float len = ba.mag();
  PVector dir = ba;
  dir.normalize();    
  
  float combinedRadius = obs.r + system.r;
    
  float dirT = pa.dot(dir);
  if (dirT > 0 && dirT < len) // might intercept middle part
  {
    float perpx = pa.x - dir.x * dirT; 
    float perpy = pa.y - dir.y * dirT; 
    float perpSq = perpx*perpx + perpy*perpy;
    if (perpSq < combinedRadius*combinedRadius) 
    {
      float scale = (combinedRadius*combinedRadius - perpSq);
      float forcex = perpx * scale;
      float forcey = perpy * scale;
      return new PVector(forcex, forcey, 0);
    }
  }
  else
  {
    if (pa.magSq() < combinedRadius*combinedRadius) 
    {
      float scale = combinedRadius*combinedRadius - pa.magSq();
      float forcex = pa.x * scale;
      float forcey = pa.y * scale;
      return new PVector(forcex, forcey, 0);      
    }
    
    if (pb.magSq() < combinedRadius*combinedRadius)
    {
      float scale = combinedRadius*combinedRadius - pb.magSq();
      float forcex = pb.x * scale;
      float forcey = pb.y * scale;
      return new PVector(forcex, forcey, 0);           
    }
  }
  return new PVector(0,0,0);
}

boolean capsule_intersect(PVector p, PVector v, Obstacle obs)
{
  PVector ba = new PVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y, 0);
  PVector pa = new PVector(p.x-obs.a.x, p.y-obs.a.y, 0);
  PVector pb = new PVector(p.x-obs.b.x, p.y-obs.b.y, 0);
  
  float len = ba.mag();
  PVector dir = ba;
  dir.normalize();    
  
  float combinedRadius = obs.r + system.r;
  float dirT = pa.dot(dir);
  if (dirT > 0 && dirT < len) // might intercept middle part
  {
    float perpx = pa.x - dir.x * dirT; 
    float perpy = pa.y - dir.y * dirT; 
    float perpSq = perpx*perpx + perpy*perpy;
    if (perpSq <combinedRadius*combinedRadius) return true;
  }
  else
  {
    if (pa.magSq() < combinedRadius*combinedRadius) return true;
    if (pb.magSq() < combinedRadius*combinedRadius) return true;
  }
  return false;
}

// return time wihen v intercepts our obstacle
HitObject intersection(PVector p, PVector v, Obstacle obs)
{
  PVector v_perp = new PVector(-v.y, v.x, 0); //<>//
  PVector ba = new PVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y, 0);
  PVector pa = new PVector(p.x-obs.a.x, p.y-obs.a.y, 0);
  
  HitObject result = new HitObject();
  float test2_numerator = PVector.dot(pa, v_perp);
  float test2_denominator = PVector.dot(ba, v_perp);
  if (abs(test2_denominator) < 0.0001)
  {
    result.success = false;
    return result;
  }
  
  float t_segment = test2_numerator / test2_denominator;
  if (t_segment < 0 || t_segment > 1.0) 
  {
    result.success = false;
    return result;    
  }
  
  float test1_numerator = ba.x*pa.y + ba.y*pa.x;
  float test1_denominator = PVector.dot(ba, v_perp);
  if (abs(test1_denominator) < 0.0001)
  {
    result.success = false;
    return result;
  }
  float t_ray = test1_numerator / test1_denominator;
  result.success = t_ray > 0;
  result.t = t_ray;
  
  //println("t_segment "+t_segment+" "+v_perp);
  //PVector test = new PVector(p.x + t_ray*v.x, p.y + t_ray*v.y, 0);
  //PVector test2 = new PVector(obs.a.x + t_segment*ba.x, obs.a.y + t_segment*ba.y, 0);
  //println("test "+test+ " "+test2);
  return result;
}

void damp_reflect(int which, Obstacle obs)
{
  // Coefficient of resitiution
  float DAMP = 0.75;
  
  // bounce back along normal direction
  PVector obsDir = PVector.sub(obs.b, obs.a);   //<>//
  PVector obsN = new PVector(-obsDir.y, obsDir.x, 0);
  obsDir.normalize();
  obsN.normalize();
  
  float velN = PVector.dot(obsN, state.velocities[which]);
  float velT = PVector.dot(obsDir, state.velocities[which]);
  float relfectVelx = -velN * DAMP * (obsN.x) + velT * (obsDir.x);
  float relfectVely = -velN * DAMP * (obsN.y) + velT * (obsDir.y); //<>//
  
  float vhN = PVector.dot(obsN, state.vh[which]);
  float vhT = PVector.dot(obsDir, state.vh[which]);
  float relfectVhx = -vhN * DAMP * obsN.x + vhT * obsDir.x;
  float relfectVhy = -vhN * DAMP * obsN.y + vhT * obsDir.y;
  
  state.velocities[which].x = relfectVelx;
  state.velocities[which].y = relfectVely;
  state.vh[which].x = relfectVhx;
  state.vh[which].y = relfectVhy;
  
  // Damp the velocities
  state.velocities[which].x *= DAMP; 
  state.vh[which].x *= DAMP;
  
  // Reflect the position and velocity
  PVector diff = PVector.sub(state.positions[which], obs.a);
  float flipDist = diff.dot(obsN); // (p-a).dot(obsN) 
  state.positions[which].x -= 2*flipDist*obsN.x;
  state.positions[which].y -= 2*flipDist*obsN.y;    
  
  //println("before "+before + " "+beforeVel+" after "+state.positions[which]+" "+state.velocities[which]);
}

void reflect_bc()
{
  // Boundaries of the computational domain

  float XMIN = 0.0;
  float XMAX = width;
  float YMIN = 0.0;
  float YMAX = height;
  for (int i = 0; i < State.NumParticles; ++i) 
  {
    if (state.positions[i].x < XMIN) damp_reflect(i, new Obstacle(0,0, 0, height));
    if (state.positions[i].x > XMAX) damp_reflect(i, new Obstacle(width,0, width, height));
    if (state.positions[i].y > YMAX) damp_reflect(i, new Obstacle(0,height, width, height));
  }
}

void keyPressed(KeyEvent e)
{
  if (e.getKey() == 'z' && obstacles.size() > 0)
  {
    obstacles.remove(obstacles.size()-1);
  }
  else if (e.getKey() == 'c')
  {
    obstacles.clear();
  }
  else if (e.getKey() == 'p')
  {
    paused = !paused;
  }
}

void mousePressed(MouseEvent e) 
{
  if (e.isControlDown())
  {
    dragNdrop = true;
    newObstacle = new Obstacle(mouseX, mouseY, 0, 0);
  }
  /*else if (paused)
  {
    fluidOffset.x = mouseX;
    fluidOffset.y = mouseY;
    init_fluid();
    //println("here");
  }*/
}

void mouseReleased(MouseEvent e) 
{    
  dragNdrop = false;
  
  if (e.isControlDown())
  {
    newObstacle.b = new PVector(mouseX, mouseY, 0);
    float dx = newObstacle.a.x - newObstacle.b.x;
    float dy = newObstacle.a.y - newObstacle.b.y;
    float len = dx*dx + dy*dy;
    if (len > 100)
    {
      //println(len);
      obstacles.add(newObstacle);
    }
  }
}

void draw() 
{
  background(0);

  if (!paused)
  {
    compute_accel();
    leapfrog_step();
  }


  for (int i = 0; i < State.NumParticles; i++)
  {
    PVector p = state.positions[i];
    float a = state.rho[i]/maxdensity;
    
    int imgi = floor(state.positions[i].x+0.5);
    int imgj = floor(state.positions[i].y+0.5);    
    color c = lerpColor(state.colors[i], img.get(imgi, imgj), 0.6);
    
    stroke(red(c)+50, green(c)+50, blue(c)+50, 255);
    //stroke(0, 0, 0, 255);
    fill(red(c), green(c), blue(c), 200);
    ellipse(p.x, p.y, system.r*2, system.r*2);
  }
  
  /*stroke(255);
  for (int i = 0; i < obstacles.size(); i++)
  {
    line(obstacles.get(i).a.x, obstacles.get(i).a.y, obstacles.get(i).b.x, obstacles.get(i).b.y);
  }*/
  
  if (dragNdrop)
  {
    line(newObstacle.a.x, newObstacle.a.y, mouseX, mouseY);
  }
}