/* vectorBlendColor - Jared Mulder, 11/10/2022
 * Personal project that started off as a test for interpolating a unit vector field, but quickly became its own art project around distorting images.
 * By default the image is formed from mapping the vector directions to hue. Pressing 'O' will reset the colors to vector directions, pressing 'P' will instead fill the image with static.
 * Dragging the mouse will push the vectors in the direction the mouse travels. Spacebar toggles the vector blending, and pressing 'N' adds a small amount of random noise to the vectors.
 * 'Q' adds a source point, 'W' adds a sink point, 'E' adds a clockwise spiral point, 'R' adds a counterclockwise spiral point, and 'T' clears all the points from the system.
 * To toggle visibility of the vector and force point indicators, press 'V'.
 *   There are 4 ways to distort the image: '1' is the static distort, where the source image is moved a predefined amount by the vectors. '2' is backwards recursion (the best one visually), where on
 * every frame each pixel updates its color based on the pixels behind its vector direction. '3' is forwards recursion, where on every frame each pixel pushes its data forwards according to its vector
 * direction (Forwards recursion looks bad because since the pixels are moving such small distances, they get locked into 45 degree angles.) '4' is complementary recursion, which is functionally the
 * same as beckwards recursion, except the pixels are moved orthogonal to the vector direction.
 *   There are some unused functions in here, like the turbulence mapping - they are more experimental ways to create and modify the image but most of them are very computationally expensive or else
 * broken in some way, so they are not currently used.
 */

PVector[][] dirField;
PVector[][] newField;
int spacing = 16;
int fWidth, fHeight;

PImage noiseMap;
ArrayList<FPoint> points;

boolean blending = false;
boolean vNoise = false;
boolean showVectors = true;
int recursion = 0;

void setup() {
  size(640, 480);
  frameRate(25);
  fWidth = width/spacing;
  fHeight = height/spacing;
  dirField = new PVector[fWidth][fHeight];
  newField = new PVector[fWidth][fHeight];
  for (int i = 0; i < fWidth; i++) {
    for (int j = 0; j < fHeight; j++) {
      dirField[i][j] = PVector.random2D();
      newField[i][j] = new PVector(0, 0);
    }
  }
  createNoise();
  points = new ArrayList<FPoint>();
}

void draw() {
  if (mousePressed) {
    ripple();
  }
  if (blending) {
    for (int i = 0; i < fWidth; i++) {
      for (int j = 0; j < fHeight; j++) {
        blend(i, j);
      }
    }
    for (FPoint point : points) {
      point.applyForce();
    }
  }
  if (vNoise) vectorNoise(4);
  for (int i = 0; i < fWidth; i++) {
    for (int j = 0; j < fHeight; j++) {
      if (newField[i][j].x != 0 || newField[i][j].y != 0) {
        dirField[i][j].add(newField[i][j]);
        if (dirField[i][j].x == 0 && dirField[i][j].y == 0) dirField[i][j].set(PVector.random2D());
        else dirField[i][j].normalize();
      }
    }
  }
  zeroField(newField);
  //Render:
  switch (recursion) {
  default:
    imageFlow();
    break;
  case 1:
    recursiveFlow();
    break;
  case 2:
    recursiveFlow2();
    break;
  case 3:
    complementFlow();
    break;
  }
  //if (recursion > 0) distort();
  if (showVectors) {
    for (FPoint point : points) {
      point.render();
    }
    for (int i = 0; i < fWidth; i++) {
      for (int j = 0; j < fHeight; j++) {
        drawVector(i, j);
      }
    }
  }
}

void keyPressed() {
  switch (key) {
  case ' ':
    if (blending) blending = false;
    else blending = true;
    break;
  case 'v':
    if (showVectors) showVectors = false;
    else showVectors = true;
    break;
  case 'n':
    if (vNoise) vNoise = false;
    else vNoise = true;
    break;
  case '1':
    recursion = 0;
    break;
  case '2':
    recursion = 1;
    break;
  case '3':
    recursion = 2;
    break;
  case '4':
    recursion = 3;
    break;
  case 'q':
    points.add(new FPoint(mouseX, mouseY, 0));
    break;
  case 'w':
    points.add(new FPoint(mouseX, mouseY, 1));
    break;
  case 'e':
    points.add(new FPoint(mouseX, mouseY, 2));
    break;
  case 'r':
    points.add(new FPoint(mouseX, mouseY, 3));
    break;
  case 't':
    points.clear();
    break;
  case 'o':
    createNoise();
    break;
  case 'p':
    createStatic();
    break;
  }
}

void ripple() {
  PVector mPos = new PVector(float(mouseX+pmouseX-spacing)/(2*spacing), float(mouseY+pmouseY-spacing)/(2*spacing));
  PVector delta = new PVector(mouseX-pmouseX, mouseY-pmouseY);
  PVector cPos = new PVector(0, 0);
  for (int i = 0; i < width; i++) {
    for (int j = -3; j < height; j++) {
      cPos.set(i, j);
      getNew(int(cPos.x), int(cPos.y)).add(PVector.div(delta, PVector.sub(mPos, cPos).magSq()*spacing+1));
    }
  }
}

void blend(int x, int y) {
  PVector blendVector = new PVector(0, 0);
  blendVector.add(getDir(x-1, y-1)).add(getDir(x-1, y))
    .add(getDir(x-1, y+1)).add(getDir(x, y-1)).add(getDir(x, y+1))
    .add(getDir(x+1, y-1)).add(getDir(x+1, y)).add(getDir(x+1, y+1));
  getNew(x, y).add(blendVector.div(8));
}

void drawVector(int x, int y) {
  int rX = x*spacing + spacing/2;
  int rY = y*spacing + spacing/2;
  circle(rX, rY, 2);
  line(rX, rY, rX+getDir(x, y).x*spacing/2, rY+getDir(x, y).y*spacing/2);
}

PVector getDir(int x, int y) {
  while (x < 0) x += fWidth;
  while (x >= fWidth) x -= fWidth;
  while (y < 0) y += fHeight;
  while (y >= fHeight) y -= fHeight;
  return dirField[x][y];
}

PVector getNew(int x, int y) {
  while (x < 0) x += fWidth;
  while (x >= fWidth) x -= fWidth;
  while (y < 0) y += fHeight;
  while (y >= fHeight) y -= fHeight;
  return newField[x][y];
}

void zeroField(PVector[][] field) {
  for (int i = 0; i < fWidth; i++) {
    for (int j = 0; j < fHeight; j++) {
      field[i][j].set(0, 0);
    }
  }
}

float getTurbulence(int x, int y) {
  PVector base = getDir(x, y);
  PVector compare = getDir(x-1, y-1).copy();
  compare.add(getDir(x-1, y)).add(getDir(x-1, y+1))
    .add(getDir(x, y-1)).add(getDir(x, y+1))
    .add(getDir(x+1, y-1)).add(getDir(x+1, y)).add(getDir(x+1, y+1));
  return -PVector.dot(base, compare.normalize());
}

PVector diff(PVector a, PVector b) {
  PVector delta = b.copy().sub(a);
  if (delta.x >= width/2) delta.x -= width;
  else if (delta.x <= -width/2) delta.x += width;
  if (delta.y >= height/2) delta.y -= height;
  else if (delta.y <= -height/2) delta.y += height;
  return delta;
}

void vectorNoise(int strength) {
  for (int i = 0; i < fWidth; i++) {
    for (int j = 0; j < fHeight; j++) {
      newField[i][j].add(PVector.random2D().mult((float)strength/16));
    }
  }
}
