/*
 * Tectonic3_Pareto - A modification of Tectonic3 where instead of each crystal growing by 1 node per cycle, instead a set number of nodes is randomly distributed to the total slots in the system.
 * I called this Pareto mode as it creates a bias towards crystals with higher surface area, which leads to the crystal size having something approximating a pareto distribution. This generally leads
 * to more cohesive shapes, with a better area to perimeter ratio.
 */

final int NODE_SIZE = 8; //Defines how large the elements are
final int NUM_CRYSTALS = 24; //Defines the number of crystals to create

Lattice mLat; //Main lattice to store the crystal data.
boolean paused = false;

void setup() { //Sets up the window environment and places a new lattice.
  size(960, 720);
  colorMode(HSB, 360, 100, 100);

  mLat = new Lattice(width/NODE_SIZE-1, height/NODE_SIZE-1, NODE_SIZE);
  mLat.addCrystal(NUM_CRYSTALS);
}

void draw() {
  background(224);
  if (!mLat.full) {
    if (!paused) {
      for (int i = 0; i < 192/NODE_SIZE; i++) mLat.growCrystals();
    }
  } else {
    noLoop();
  }
  mLat.render();
}

void keyPressed() {
  if (keyCode == ENTER) {
    paused = paused ? false : true; //Enter toggles the paused state
  } else if (key == ' ') { //Spacebar attempts to calculate the node values and prints it to the console and to a file.
    try {
      mLat.calcStats();
    }
    catch (IOException e) {
      print(e);
      return;
    }
  }
  redraw();
}
