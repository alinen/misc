class System
{
   constructor() 
   {
      this.h = 16; // particle neighborhood size
      this.r = 4; // particle size
      this.dt = 0.1; // time step
      this.rho0 = 1000; // reference density
      this.k = 800; //bulk modulus
      this.mu = 9000.1; // viscosity
      this.g = 0.0; // gravity strength
   }  
};

class State
{
   constructor()
   {
      this.NumParticles = 2500; // number of particles
      this.mass = 0; // mass
      this.positions = [] //vector;
      this.velocities = [] //vector;
      this.vh = [] //vector;
      this.accelerations = []; //vector
      this.rho = [];  // floats
      this.maxdensity = 0;
      this.paused = true;
      this.intersection = []; // booleans

      for (var i = 0; i < this.NumParticles; i++)
      {
         this.positions.push(createVector(0,0));
         this.velocities.push(createVector(0,0));
         this.vh.push(createVector(0,0));
         this.accelerations.push(createVector(0,0));
         this.rho.push(0);
         this.intersection.push(false);
      }
   }
};

class HitObject
{
   constructor()
   {
      this.success;
      this.t;
   }
};

class Obstacle
{
  constructor(ax, ay, bx, by)
  {
     this.a = createVector(ax, ay);
     this.b = createVector(bx, by);
     this.r = 10.0;
  }
};

var state = 0;
var params = 0;
var newObstacle = 0;
var obstacles = [];
var dragNdrop = false;
var fluidOffset = 0;

function setup() 
{
   state = new State();
   params = new System();
   newObstacle = new Obstacle();
   obstacles = []; // list of obstacles

   dragNdrop = false;
   fluidOffset = createVector(0,0);

   // graphics setup
   createCanvas(512, 512);
   smooth();
   strokeWeight(1);
   background(0);
   fill(255);
  
   init_fluid();
  
   state.positions[0].y = 241;
   state.velocities[0].y = -20;
   damp_reflect(0, new Obstacle(0,height, width, height));
} //<>//

function init_fluid()
{
  var numcols = width / (2*params.r);
  var margin = 0;
  for (var i = 0; i < state.NumParticles; i++)
  {
     var cellj = i % numcols;
     var celli = floor(i/numcols);
     var x = params.r+cellj*(2*params.r + margin);
     var y = params.r+celli*(2*params.r + margin);
     state.positions[i] = createVector(x, y);
     state.positions[i].x += fluidOffset.x;
     state.positions[i].y += fluidOffset.y;
     state.velocities[i] = createVector(0,0);
     state.accelerations[i] = createVector(0,0);
     state.vh[i] = createVector(0,0);
  }
  
  normalize_mass();
  compute_accel();
  leapfrog_start();
}

function compute_density()
{
   state.maxdensity = 0;
   var h = params.h;
   var h2 = h*h;
   var h8 = ( h2*h2 )*( h2*h2 );
   var C = 4 * state.mass / 3.14 / h8;
   for (var i = 0; i < state.NumParticles; i++) state.rho[i] = 0;
   for (var i = 0; i < state.NumParticles; ++i) 
   {
      state.rho[i] += 4 * state.mass / 3.14 / h2;
      for (var j = i+1; j < state.NumParticles; ++j) 
      {
         var dx = state.positions[i].x - state.positions[j].x;
         var dy = state.positions[i].y - state.positions[j].y;
         var r2 = dx*dx + dy*dy;
         var z = h2-r2;
         if (z > 0) 
         {
            var rho_ij = C*z*z*z;
            state.rho[i] += rho_ij;
            state.rho[j] += rho_ij;
         }
      }
   }  
   
   for (var i = 0; i < state.NumParticles; i++) state.maxdensity = max(state.maxdensity, state.rho[i]);
}

function normalize_mass()
{
   state.mass = 1;
   compute_density();
   var rho0 = params.rho0;
   var rho2s = 0;
   var rhos = 0;
   for (var i = 0; i < state.NumParticles; ++i) 
   {
      rho2s += (state.rho[i])*(state.rho[i]);
      rhos += state.rho[i];
   }
   state.mass *= ( rho0*rhos / rho2s );
}

function compute_accel()
{
  // Unpack basic parameters
  var h = params.h;
  var rho0 = params.rho0;
  var k = params.k;
  var mu = params.mu;
  var mass = state.mass;
  var h2 = h*h;

  // Compute density and color
  compute_density();

  // Start with gravity and surface forces
  for (var i = 0; i < state.NumParticles; ++i) 
  {
    state.accelerations[i].x = 0;
    state.accelerations[i].y = params.g;
    for (var j = 0; j < obstacles.length; j++)
    {
      var b = capsule_intersect(state.positions[i], state.velocities[i], obstacles[j]);
      //if (b === true)
      {
        // compute repellent force
        var force = capsule_force(state.positions[i], state.velocities[i], obstacles[j]);
        state.accelerations[i].x -= force.x;
        state.accelerations[i].y -= force.y;        
      }
    }    
  }
  
  // Constants for interaction term
  var C0 = mass / 3.14 / ( (h2)*(h2) );
  var Cp = 15*k;
  var Cv = -40*mu;
  
  // Now compute interaction forces
  for (var i = 0; i < state.NumParticles; ++i) 
  {
    var rhoi = state.rho[i];
    for (var j = i+1; j < state.NumParticles; ++j) 
    {
      var dx = state.positions[i].x-state.positions[j].x;
      var dy = state.positions[i].y-state.positions[j].y;
      var r2 = dx*dx + dy*dy;      
      if (r2 < h2) 
      {
        var rhoj = state.rho[j];
        var q = sqrt(r2)/h;
        var u = 1-q;
        var w0 = C0 * u/rhoi/rhoj;
        var wp = w0 * Cp * (rhoi+rhoj-2*rho0) * u/q;
        var wv = w0 * Cv;
        var dvx = state.velocities[i].x - state.velocities[j].x;
        var dvy = state.velocities[i].y - state.velocities[j].y;
        
        state.accelerations[i].x += (wp*dx + wv*dvx);
        state.accelerations[i].y += (wp*dy + wv*dvy);
        
        state.accelerations[j].x -= (wp*dx + wv*dvx);
        state.accelerations[j].y -= (wp*dy + wv*dvy);
      }
    }
  }
}

function leapfrog_step()
{
  var maxacc = 100;
  for (var i = 0; i < state.NumParticles; ++i)
  {
    var mag = sqrt(state.accelerations[i].x*state.accelerations[i].x + 
        state.accelerations[i].y*state.accelerations[i].y);
      
    if (mag > maxacc) 
    {
      state.accelerations[i].x = state.accelerations[i].x/mag * maxacc;
      state.accelerations[i].y = state.accelerations[i].y/mag * maxacc;
    }
    state.vh[i].x += state.accelerations[i].x * params.dt;
    state.vh[i].y += state.accelerations[i].y * params.dt;
  }
  for (var i = 0; i < state.NumParticles; ++i)
  {
    state.velocities[i].x = state.vh[i].x + state.accelerations[i].x * params.dt / 2;
    state.velocities[i].y = state.vh[i].y + state.accelerations[i].y * params.dt / 2;
  }
  for (var i = 0; i < state.NumParticles; ++i)
  {
    state.positions[i].x += state.vh[i].x * params.dt;
    state.positions[i].y += state.vh[i].y * params.dt;
  }
  reflect_bc();
}

function leapfrog_start()
{
  for (var i = 0; i < state.NumParticles; ++i)
  {
    state.vh[i].x = state.velocities[i].x + state.accelerations[i].x * params.dt / 2;
    state.vh[i].y = state.velocities[i].y + state.accelerations[i].y * params.dt / 2;
  }
  for (var i = 0; i < state.NumParticles; ++i)
  {
    state.velocities[i].x += state.accelerations[i].x * params.dt;
    state.velocities[i].y += state.accelerations[i].y * params.dt;
  }
  for (var i = 0; i < state.NumParticles; ++i)
  {
    state.positions[i].x += params.dt * state.vh[i].x;
    state.positions[i].y += params.dt * state.vh[i].y;
  }
  reflect_bc();
}

function capsule_force(p, v, obs)
{
  var ba = createVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y);
  var pa = createVector(p.x-obs.a.x, p.y-obs.a.y);
  var pb = createVector(p.x-obs.b.x, p.y-obs.b.y);
  
  var len = ba.mag();
  var dir = ba;
  dir.normalize();    
  
  var combinedRadius = obs.r + params.r;
    
  var dirT = pa.dot(dir);
  if (dirT > 0 && dirT < len) // might intercept middle part
  {
    var perpx = pa.x - dir.x * dirT; 
    var perpy = pa.y - dir.y * dirT; 
    var perpSq = perpx*perpx + perpy*perpy;
    if (perpSq < combinedRadius*combinedRadius) 
    {
      var scale = (combinedRadius*combinedRadius - perpSq);
      var forcex = perpx * scale;
      var forcey = perpy * scale;
      return createVector(forcex, forcey);
    }
  }
  else
  {
    if (pa.magSq() < combinedRadius*combinedRadius) 
    {
      var scale = combinedRadius*combinedRadius - pa.magSq();
      var forcex = pa.x * scale;
      var forcey = pa.y * scale;
      return createVector(forcex, forcey);
    }
    
    if (pb.magSq() < combinedRadius*combinedRadius)
    {
      var scale = combinedRadius*combinedRadius - pb.magSq();
      var forcex = pb.x * scale;
      var forcey = pb.y * scale;
      return createVector(forcex, forcey);
    }
  }
  return createVector(0,0);
}

function capsule_intersect(p, v, obs)
{
  var ba = createVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y);
  var pa = createVector(p.x-obs.a.x, p.y-obs.a.y);
  var pb = createVector(p.x-obs.b.x, p.y-obs.b.y);
  
  var len = ba.mag();
  var dir = ba;
  dir.normalize();    
  
  var combinedRadius = obs.r + params.r;
  var dirT = pa.dot(dir);
  if (dirT > 0 && dirT < len) // might intercept middle part
  {
    var perpx = pa.x - dir.x * dirT; 
    var perpy = pa.y - dir.y * dirT; 
    var perpSq = perpx*perpx + perpy*perpy;
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
function intersection(p, v, obs)
{
  var v_perp = createVector(-v.y, v.x); //<>//
  var ba = createVector(obs.b.x-obs.a.x, obs.b.y-obs.a.y);
  var pa = createVector(p.x-obs.a.x, p.y-obs.a.y);
  
  var result = new HitObject();
  var test2_numerator = p5.Vector.dot(pa, v_perp);
  var test2_denominator = p5.Vector.dot(ba, v_perp);
  if (abs(test2_denominator) < 0.0001)
  {
    result.success = false;
    return result;
  }
  
  var t_segment = test2_numerator / test2_denominator;
  if (t_segment < 0 || t_segment > 1.0) 
  {
    result.success = false;
    return result;    
  }
  
  var test1_numerator = ba.x*pa.y + ba.y*pa.x;
  var test1_denominator = p5.Vector.dot(ba, v_perp);
  if (abs(test1_denominator) < 0.0001)
  {
    result.success = false;
    return result;
  }
  var t_ray = test1_numerator / test1_denominator;
  result.success = t_ray > 0;
  result.t = t_ray;
  
  //p5.Vector test = new p5.Vector(p.x + t_ray*v.x, p.y + t_ray*v.y, 0);
  //p5.Vector test2 = new p5.Vector(obs.a.x + t_segment*ba.x, obs.a.y + t_segment*ba.y, 0);
  return result;
}

function damp_reflect(which, obs)
{
  // Coefficient of resitiution
  var DAMP = 0.75;
  
  // bounce back along normal direction
  var obsDir = p5.Vector.sub(obs.b, obs.a);   //<>//
  var obsN = createVector(-obsDir.y, obsDir.x);
  obsDir.normalize();
  obsN.normalize();
  
  var velN = p5.Vector.dot(obsN, state.velocities[which]);
  var velT = p5.Vector.dot(obsDir, state.velocities[which]);
  var relfectVelx = -velN * DAMP * (obsN.x) + velT * (obsDir.x);
  var relfectVely = -velN * DAMP * (obsN.y) + velT * (obsDir.y); //<>//
  
  var vhN = p5.Vector.dot(obsN, state.vh[which]);
  var vhT = p5.Vector.dot(obsDir, state.vh[which]);
  var relfectVhx = -vhN * DAMP * obsN.x + vhT * obsDir.x;
  var relfectVhy = -vhN * DAMP * obsN.y + vhT * obsDir.y;
  
  state.velocities[which].x = relfectVelx;
  state.velocities[which].y = relfectVely;
  state.vh[which].x = relfectVhx;
  state.vh[which].y = relfectVhy;
  
  // Damp the velocities
  state.velocities[which].x *= DAMP; 
  state.vh[which].x *= DAMP;
  
  // Reflect the position and velocity
  var diff = p5.Vector.sub(state.positions[which], obs.a);
  var flipDist = diff.dot(obsN); // (p-a).dot(obsN) 
  state.positions[which].x -= 2*flipDist*obsN.x;
  state.positions[which].y -= 2*flipDist*obsN.y;    
}

function reflect_bc()
{
  // Boundaries of the computational domain

  var XMIN = 0.0;
  var XMAX = width;
  var YMIN = 0.0;
  var YMAX = height;
  for (var i = 0; i < state.NumParticles; ++i) 
  {
    if (state.positions[i].x < XMIN) damp_reflect(i, new Obstacle(0,0, 0, height));
    if (state.positions[i].x > XMAX) damp_reflect(i, new Obstacle(width,0, width, height));
    if (state.positions[i].y > YMAX) damp_reflect(i, new Obstacle(0,height, width, height));
  }
}

function keyPressed()
{
  if (keyCode === 90 && obstacles.length > 0) // z
  {
    obstacles.splice(obstacles.length - 1, 1);
  }
  else if (keyCode === 67) // c
  {
    obstacles = [];
  }
  else if (keyCode === 80) // p
  {
    state.paused = !state.paused;
  }
}

function mousePressed() 
{
  if (keyIsDown(17)) //ctrl
  {
    dragNdrop = true;
    newObstacle = new Obstacle(mouseX, mouseY, 0, 0);
  }
  else if (state.paused)
  {
    fluidOffset.x = mouseX;
    fluidOffset.y = mouseY;
    init_fluid();
  }
}

function mouseReleased() 
{    
  dragNdrop = false;
  
  if (keyIsDown(17)) //ctrl
  {
     newObstacle.b = createVector(mouseX, mouseY);
     var dx = newObstacle.a.x - newObstacle.b.x;
     var dy = newObstacle.a.y - newObstacle.b.y;
     var len = dx*dx + dy*dy;
     if (len > 100)
     {
        obstacles.push(newObstacle);
     }
  }
}

function draw() 
{

  if (!state.paused)
  {
    compute_accel();
    leapfrog_step();
  }

  //noStroke();
  for (var i = 0; i < state.NumParticles; i++)
  {
    var p = state.positions[i];
    var c = state.rho[i]/state.maxdensity;
    var amag = sqrt(state.accelerations[i].x*state.accelerations[i].x + 
        state.accelerations[i].y*state.accelerations[i].y);
    if (state.intersection[i])
    {
      fill(c*255, 255, 0);
    }
    else
    {
      var from = color(255,0,0);
      var to = color(255, 0, 255); 
      var ecolor = lerpColor(from, to, amag/125.0);
      fill(ecolor);
    }
    ellipse(p.x, p.y, params.r*2, params.r*2);
  }
  
  //stroke(255);
  //for (var i = 0; i < obstacles.length; i++)
  //{
    //line(obstacles[i].a.x, obstacles[i].a.y, obstacles[i].b.x, obstacles[i].b.y);
  //}
  
  if (dragNdrop)
  {
    line(newObstacle.a.x, newObstacle.a.y, mouseX, mouseY);
  }
}

