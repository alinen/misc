// Peg Board Task
// Aline Normoyle, alinen

class PegBoard {

  constructor() {
    this.w = 1000.0;
    this.h = 1000.0;
    this.spacing = 100;
    this.pegSize = 50;
    this.rotateRate = 0.05; // radians
    this.half = 0; 
    this.numPegs = 0;
    this.selected = {i: 0, j: 0, theta: 0}; 
  }

  setup(width, height) {
    this.w = width;
    this.h = height;
    this.half = this.spacing * 0.5;
    this.numPegs = floor(this.w / this.spacing);
  };

  draw() {
    noStroke();
    fill("#fff8dc");
    rectMode(CORNER);
    rect(0, 0, this.w, this.h);

    fill("#bc8f8f");
    rectMode(CENTER);
    for (let i = 0; i < this.numPegs; i++) {
      for (let j = 0; j < this.numPegs; j++) {
        let x = this.half + this.spacing * i; 
        let y = this.half + this.spacing * j; 

        // ellipse(x, y, 10, 10); // circle peg
        if (i == this.selected.i && j == this.selected.j) {
          push();
          translate(x, y);
          rotate(this.selected.theta);
          rect(0, 0, this.pegSize, this.pegSize, 5, 5, 5, 5); // roundRect
          pop();
          this.selected.theta += this.rotateRate;
          if (this.selected.theta >= HALF_PI) {
             this.selected.i = -1;
             this.selected.j = -1;
          }
        }
        else {
          rect(x, y, this.pegSize, this.pegSize, 5, 5, 5, 5); // roundRect
        }
      }
    }
  };

  mouseClicked(x, y) {
    if (this.selected.i != -1) return; // only allow a single click

    let celli = x % this.spacing;
    let cellj = y % this.spacing;
    //console.log("here "+mouseX+" "+mouseY+" "+celli+" "+cellj);

    if (dist(celli, cellj, this.half, this.half) < this.pegSize/2) {
      this.selected.i = floor(x / this.spacing);
      this.selected.j = floor(y / this.spacing);
      this.selected.theta = 0;
    }
  }
};