class FPoint {
  FPoint(float iX, float iY, int iT) {
    position = new PVector(iX, iY);
    type = iT;
  }

  PVector position;
  int type;

  void render() {
    switch (type) {
    case 0:
      fill(16, 16, 225);
      break;
    case 1:
      fill(255, 136, 16);
      break;
    case 2:
      fill(16, 255, 16);
      break;
    case 3:
      fill(136, 16, 255);
      break;
    }
    noStroke();
    circle(position.x, position.y, 8);
    stroke(0);
  }

  void applyForce() {
    for (int i = 0; i < fWidth; i++) {
      for (int j = 0; j < fHeight; j++) {
        switch (type) {
        case 0: //0 = Repuslion
          repulse(i, j);
          break;
        case 1: //1 = Attraction
          attract(i, j);
          break;
        case 2: //2 = Right-Hand Swirl
          rSwirl(i, j);
          break;
        case 3: //3 = Right-Hand Swirl
          lSwirl(i, j);
          break;
        }
      }
    }
  }

  private void repulse(int i, int j) {
    PVector delta = diff(position, new PVector(i*spacing, j*spacing));
    getNew(i, j).add(delta.div(delta.magSq()*spacing+1).mult(40));
  }

  private void attract(int i, int j) {
    PVector delta = diff(position, new PVector(i*spacing, j*spacing));
    getNew(i, j).add(delta.div(delta.magSq()*spacing+1).mult(-40));
  }

  private void rSwirl(int i, int j) {
    PVector delta = diff(position, new PVector(i*spacing, j*spacing));
    float tempY = delta.y;
    delta.y = delta.x;
    delta.x = -tempY;
    getNew(i, j).add(delta.div(delta.magSq()*spacing+1).mult(40));
  }

  private void lSwirl(int i, int j) {
    PVector delta = diff(position, new PVector(i*spacing, j*spacing));
    float tempY = delta.y;
    delta.y = delta.x;
    delta.x = -tempY;
    getNew(i, j).add(delta.div(delta.magSq()*spacing+1).mult(-40));
  }
}
