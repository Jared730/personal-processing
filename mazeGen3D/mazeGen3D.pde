/* mazeGen3D - Jared Mulder, 11/15/2022
 * Procedurally generates a maze by expanding outwards from a single point. The maze is effeciently stored as an array of bytes, and bitwise math is used to calculate new valid tiles.
 * Controls: LMB - place tile manually; RMB - overwrite tile; SPACE - grow maze by 1 tile; ENTER - grow maze until no available spaces remain; P - print maze statistics to console;
 * TAB - switch between 2D and 3D mode; W - Move camera forward in 3D; S - Move camera backward in 3D; A - Move camera left in 3D; D - Move camer right in 3D; 
 * Z - Move camera up in 3D; X - Move camera down in 3D; Arrow keys - Control camera direction in 3D.
 */

Maze maze1;
boolean devMode;
PVector camPos;
float camPitch;
float camYaw;

void setup() {
  size(640, 480, P3D);
  maze1 = new Maze(40, 30);
  devMode = true;
  camPos = new PVector(0, 0, 16);
  camPitch = 0;
  camYaw = 0;
}

void draw() {
  background(192);
  if (devMode) {
    camera();
    drawMaze(maze1);
  } else {
    if (keyPressed) controlCheck();
    beginCamera();
    camera();
    translate(width/2, height/2, camPos.z);
    rotateX(camPitch);
    rotateZ(camYaw);
    translate(camPos.x-width/2, camPos.y-height/2, 0);
    endCamera();
    drawMaze3D(maze1);
  }
}

void controlCheck() {
  if (key == 'w') camPos.y+=2;
  else if (key == 's') camPos.y-=2;
  else if (key == 'a') camPos.x+=2;
  else if (key == 'd') camPos.x-=2;
  else if (key == 'z') camPos.z+=2;
  else if (key == 'x') camPos.z-=2;
  else if (key == CODED) {
    if (keyCode == UP) camPitch+=PI/180;
    else if (keyCode == DOWN) camPitch-=PI/180;
    else if (keyCode == LEFT) camYaw+=PI/180;
    else if (keyCode == RIGHT) camYaw-=PI/180;
  }
}

void mousePressed() {
  if (devMode) {
    if (mouseButton == LEFT) {
      maze1.generateTile(int(mouseX/16), int(mouseY/16));
    } else if (mouseButton == RIGHT) {
      maze1.overwriteTile(int(mouseX/16), int(mouseY/16));
    }
  }
}

void keyPressed() {
  if (key == TAB) {
    if (devMode) devMode = false;
    else devMode = true;
  } else if (devMode) {
    switch (key) {
    case ' ':
      maze1.growMaze();
      break;
    case 'p':
      maze1.countTiles();
      break;
    case ENTER:
      maze1.fillMaze();
      break;
    }
  } else {
    if (key == ' ') {
      camPos.set(0, 0, 16);
    }
  }
}

void drawMaze(Maze maze) {
  noStroke();
  for (int y = 0; y < maze.mHeight; y++) {
    for (int x = 0; x < maze.mWidth; x++) {
      byte tile = maze.getTile(x, y);
      if ((tile & 0xF0) == 0x80) fill(128);
      else fill(32);
      rect(x*16, y*16, 16, 16);
      fill(224);
      if ((tile & RT) == RT) rect(x*16+4, y*16+4, 12, 8);
      if ((tile & UT) == UT) rect(x*16+4, y*16, 8, 12);
      if ((tile & LT) == LT) rect(x*16, y*16+4, 12, 8);
      if ((tile & DT) == DT) rect(x*16+4, y*16+4, 8, 12);
    }
  }
  noFill();
  for (PVector qPos : maze.tileQueue) {
    if (maze.getTile(int(qPos.x), int(qPos.y)) >= 0) stroke(224, 120, 16);
    else stroke(16, 224, 16);
    rect(int(qPos.x)*16, int(qPos.y)*16, 16, 16);
  }
}
