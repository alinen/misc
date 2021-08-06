// Angry Birds
// Daniel Shiffman
// https://thecodingtrain.com/CodingChallenges/138-angry-birds.html
// https://youtu.be/TDQzoe9nslY

const { Engine, World, Bodies, Mouse, MouseConstraint, Constraint } = Matter;
let ground = null;
let boxes = [];
let bird = null;
let world = null;
let engine = null;
let mConstraint = null;
let slingshot = null;

let dotImg = null;
let boxImg = null;
let bkgImg = null;

class AngryBirds {

  constructor() {
    this.w = 0;
    this.h = 0;
  }
  
  preload() {
    dotImg = loadImage('images/dot.png');
    boxImg = loadImage('images/equals.png');
    bkgImg = loadImage('images/skyBackground.png');
  }
  
  setup(canvas, offsetx, w, h) {
    this.w = w;
    this.h = h;
    this.offsetx = offsetx;
    engine = Engine.create();
    world = engine.world;
    ground = new Ground(offsetx + w / 2, h - 10, w, 20);
    for (let i = 0; i < 3; i++) {
      boxes[i] = new Box(offsetx + 450, 300 - i * 75, 84, 100); // hard-codes position
    }
    bird = new Bird(offsetx + 150, 300, 25);
  
    slingshot = new SlingShot(offsetx + 150, 300, bird.body);
  
    const mouse = Mouse.create(canvas.elt);
    const options = {
      mouse: mouse
    };
  
    // A fix for HiDPI displays
    mouse.pixelRatio = pixelDensity();
    mConstraint = MouseConstraint.create(engine, options);
    World.add(world, mConstraint);
  }
  
  keyPressed() {
    if (key == ' ') {
      World.remove(world, bird.body);
      bird = new Bird(this.offsetx + 150, 300, 25);
      slingshot.attach(bird.body);
    }
  }
  
  mouseReleased() {
    setTimeout(() => {
      slingshot.fly();
    }, 100);
  }
  
  draw() {
    image(bkgImg, this.offsetx, 0);
    Matter.Engine.update(engine);
    ground.show();
    for (let box of boxes) {
      box.show();
    }
    slingshot.show();
    bird.show();
  }
};