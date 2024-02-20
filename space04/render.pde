void renderBackground() {
  stroke(255);
  strokeWeight(8*rScale);
  fill(16);
  rect((rOffsetX-8)*rScale, (rOffsetY-8)*rScale, (fieldWidth+16)*rScale, (fieldHeight+16)*rScale);
  image(background, rOffsetX*rScale, rOffsetY*rScale, fieldWidth*rScale, fieldHeight*rScale);
}

void createBackground() { //Creates the background nebula+stars before starting in order to prevent lag
  background = createImage(fieldWidth, fieldHeight, RGB);
  background.loadPixels();
  float dX; //Temp floats to prevent integer division
  float dY;
  for (int y = 0; y<fieldHeight; y++) { //Draw nebula
    for (int x = 0; x<fieldWidth; x++) {
      dX = x;
      dY = y;
      background.pixels[y*fieldWidth+x] = color(16+16*noise(dX/450, dY/450, 2), 16+16*noise(dX/450, dY/450, 1), 16+32*noise(dX/500, dY/500, 0));
    }
  }

  for (int i = 0; i<fieldWidth; i++) { //Draw stars
    dX = int(random(fieldWidth));
    dY = int(random(fieldHeight));
    switch(int(random(4))) {
    case 0:
      background.pixels[int(dY*fieldWidth+dX)] = color(255); //White star
      break;
    case 1:
      background.pixels[int(dY*fieldWidth+dX)] = color(255, 240, 128); //Yellow star
      break;
    case 2:
      background.pixels[int(dY*fieldWidth+dX)] = color(224, 64, 32); //Red star
      break;
    case 3:
      background.pixels[int(dY*fieldWidth+dX)] = color(192, 240, 255); //Blue star
      break;
    }
  }
  background.updatePixels();
}

final PShape createShipBody() { //Function to create the ship shape
  color shipColor = color(255);
  PShape ship;
  ship = createShape();
  ship.beginShape();
  ship.fill(shipColor);
  ship.vertex(8, 0);
  ship.vertex(-8, -8);
  ship.vertex(-4, 0);
  ship.vertex(-8, 8);
  ship.endShape(CLOSE);
  return ship;
}

PShape createMarker() {
  PShape corner = createShape();
  corner.beginShape();
  corner.noFill();
  corner.stroke(color(255,255,0));
  corner.vertex(12,4);
  corner.vertex(16,0);
  corner.vertex(12,-4);
  corner.endShape();
  return corner;
}
