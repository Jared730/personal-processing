class Station {
  final PVector position;
  PShape mCorner;
  ArrayList<PVector> sharedMemory; //Station memory to share between ships.
  int stores;
  Station() {
    position = new PVector(random(32, fieldWidth-32), random(32, fieldHeight-32));
    sharedMemory = new ArrayList<PVector>();
    stores = 0;
    mCorner = createMarker();
  }
  
  void render() {
    stroke(0);
    strokeWeight(rScale);
    fill(255);
    circle((position.x+rOffsetX)*rScale, (position.y+rOffsetY)*rScale, 32*rScale);
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(16*rScale);
    text(stores, (position.x+rOffsetX)*rScale, (position.y+rOffsetY-4)*rScale);
    renderMemory();
  }
  
  void renderMemory() {
    noFill();
    stroke(255,32,32);
    strokeWeight(2*rScale);
    mCorner.resetMatrix();
    mCorner.scale(rScale);
    for(PVector entry : sharedMemory) {
      shape(mCorner,(entry.x+rOffsetX)*rScale, (entry.y+rOffsetY)*rScale);
      mCorner.rotate(HALF_PI);
      shape(mCorner,(entry.x+rOffsetX)*rScale, (entry.y+rOffsetY)*rScale);
      mCorner.rotate(HALF_PI);
      shape(mCorner,(entry.x+rOffsetX)*rScale, (entry.y+rOffsetY)*rScale);
      mCorner.rotate(HALF_PI);
      shape(mCorner,(entry.x+rOffsetX)*rScale, (entry.y+rOffsetY)*rScale);
    }
  }
  
}

class Memory { //Simple class to store details of a memory entry.
  PVector position;
  boolean firstHand;
  Memory(PVector setPos, boolean obs) {
    position = setPos.copy();
    firstHand = obs;
  }
}
