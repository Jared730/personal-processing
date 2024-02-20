class Asteroid {
  PVector position;
  PShape shape;
  float size;
  
  Asteroid() {
    position = new PVector(random(16,fieldWidth-16), random(16, fieldHeight-16));
    size = random(4,16);
    createAsteroid();
  }
  
  void render() {
    shape.resetMatrix();
    shape.scale(rScale);
    shape(shape, (position.x+rOffsetX)*rScale, (position.y+rOffsetY)*rScale);
  }
  
  void reduce() {
    size -= 1;
    if (size >= 4) {
      createAsteroid();
    }
  }
  
  void createAsteroid() {
    PVector shapeV = PVector.random2D();
    shape = createShape();
    shape.beginShape();
    shape.fill(128, 128, 128);
    shape.stroke(0);
    shape.strokeWeight(1);
    for (int i = 0; i<ceil(size); i++) {
      shapeV.mult(size+random(4)-2);
      shape.vertex(shapeV.x, shapeV.y);
      shapeV.rotate(TWO_PI/ceil(size));
      shapeV.normalize();
    }
    shape.endShape(CLOSE);
  }
}
