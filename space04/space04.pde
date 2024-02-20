// Space04 - Jared Mulder, 2/16/2022
// Small colony simulation with a bunch of ships mining asteroids and bring the resources back to their station.
// This is mainly a test of AI memory. Each of the ships has a memory of asteroids they have seen, and they share this memory with the stations database when stopping by.
// Other ships can then copy the stations database to learn about new possible asteroid locations in order to increase effeciency.
// Ships will only share memories of asteroids they have seen. This helps avoid outdated references from being re-added.

//TODO: Program better emergent behavior - If a ship sees that all of the nearby ships are going to the same site for mining, it should decide to scout instead.

PImage background; //Background image, created procedurally on startup.
int fieldWidth, fieldHeight; //width and height of the simulation field.
float rOffsetX, rOffsetY, rScale; //for controlling the camera position.
ArrayList<Asteroid> asteroids; //List of asteroids.
ArrayList<Computer> ships; //List of computer-controlled ships.
boolean pause;
Station testStation;
PauseButton pauseButton;

void setup() {
  size(768, 512);
  surface.setResizable(true); //Note: This is optimized poorly and zooming in too much will seriously lag the system.
  background(16);
  rOffsetX = 0;
  rOffsetY = 0;
  fieldWidth = 1024;
  fieldHeight = 1024;
  rScale = 0.5;
  pause = false;
  pauseButton = new PauseButton(height/16, height/16, height/12, height/12);
  frameRate(60);

  print("Loading... Creating Background... ");
  createBackground();
  testStation = new Station();
  asteroids = new ArrayList<Asteroid>();
  ships = new ArrayList<Computer>();
  print("Creating Asteroids... ");
  for (int i = 0; i<8; i++) {
    asteroids.add(new Asteroid());
  }
  print("Creating Ships... ");
  for (int i = 0; i<20; i++) {
    ships.add(new Computer(testStation));
  }
  println("complete!");
}

void draw() {
  background(16);
  renderBackground();
  if (pause == false) {
    for (Computer ship : ships) {
      ship.compute();
      ship.update();
    }
  }

  asteroids.removeIf(Asteroid->Asteroid.size<4);
  if (asteroids.size() < 6) {
    asteroids.add(new Asteroid());
  }
  for (Asteroid asteroid : asteroids) {
    asteroid.render();
  }

  testStation.render();
  for (Computer ship : ships) {
    ship.renderAI();
  }
  pauseButton.update();
}

void mouseWheel(MouseEvent event) {
  float wheel = event.getCount();
  if (wheel > 0 && rScale > 0.125) { //Zoom out
    rOffsetX += mouseX/rScale;
    rOffsetY += mouseY/rScale;
    rScale = rScale / 2;
  } else if (wheel < 0 && rScale < 8) { //Zoom in
    rScale = rScale * 2;
    rOffsetX -= mouseX/rScale;
    rOffsetY -= mouseY/rScale;
  }
}

void mousePressed() {
  if (pauseButton.mOver() == true) {
    if (pause == false) {
      pause = true;
    } else {
      pause = false;
    }
    pauseButton.pressed = true;
  }
}

void mouseReleased() {
  pauseButton.pressed = false;
}

void mouseDragged() {
  if (pauseButton.mOver() == true) return;
  rOffsetX += (mouseX-pmouseX)/rScale;
  rOffsetY += (mouseY-pmouseY)/rScale;
}

void keyPressed() {
  if (keyCode == ENTER || keyCode == RETURN) {
    PVector mPos = new PVector(mouseX/rScale-rOffsetX, mouseY/rScale-rOffsetY);
    for (Computer ship : ships) {
      if (PVector.sub(mPos, ship.position).magSq() < sq(32)) {
        if (ship.selected == false) {
          ship.selected = true;
        } else {
          ship.selected = false;
        }
        continue;
      }
    }
  } else if (key == ' ') {
    if (pause == false) {
      pause = true;
    } else {
      pause = false;
    }
  }
}
