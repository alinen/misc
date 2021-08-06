let game = new AngryBirds();
let task = new PegBoard();
let w = 0;
let clicks = [];

function preload() {
  game.preload();
}

function setup() {
  w = window.innerWidth / 2;
  const canvas = createCanvas(w*2, 400);
  task.setup(w, 400);
  game.setup(canvas, w, w, 400);
}

function keyPressed() {
  game.keyPressed();
}

function mousePressed() {
  var seconds = millis()/1000.0;
  if (mouseX < w) {
    task.mouseClicked(mouseX, mouseY);
    clicks.push({type:"task-press",x:mouseX,y:mouseY,time:seconds});
  }
  else {
    clicks.push({type:"game-press",x:mouseX,y:mouseY,time:seconds});
  }
}

function mouseReleased() {
  var seconds = millis()/1000.0;
  if (mouseX < w) {
    clicks.push({type:"task-release",x:mouseX,y:mouseY,time:seconds});
  }
  else {
    game.mouseReleased();
    clicks.push({type:"game-release",x:mouseX,y:mouseY,time:seconds});
  }
}

function draw() {
  background(255);
  task.draw();
  game.draw();

  // draw timer
  strokeWeight(1);
  fill(0);
  stroke(0);
  var seconds = millis()/1000.0;
  text(seconds.toFixed(1) + " s", 5, 15);
}

function saveExperiment(pid) {
  console.log("PID:"+pid);

  var contents = "";
  clicks.forEach(click => contents += click.type+","+click.time+","+click.x+","+click.y+"\n"); 

  var blob = new Blob([contents], {type: "text/csv;charset=utf-8"});
  var a = document.createElement("a");
  var url = URL.createObjectURL(blob);
  a.href = url;
  a.download = pid+"-clicks-"+Date()+".csv";
  document.body.appendChild(a);
  a.click();
  setTimeout(function() {
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
  }, 0);
}