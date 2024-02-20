class Computer extends Ship { //Not all ships are computer-controlled, but all computer-controlled ships are ships.
  PVector target; //Where the computer is aiming to reach.
  PVector emptyMark; //Remember if the last target in memory was empty as to inform the station.
  Station home; //Pointer to reference its home station for targeting and exchange.
  ArrayList<Memory> memory; //Memory of what the ship has seen -- Memory class contains position as well as source.
  int mode; //0=Scouting, 1=Mining, 2=Returning.
  
  Computer(Station homeStation) {
    mode = 0;
    target = new PVector(random(16, fieldWidth-16), random(16, fieldHeight-16));
    home = homeStation;
    position.set(home.position.copy());
    emptyMark = new PVector(-1, -1); //-1,-1 is an invalid position so it can represent null.
    memory = new ArrayList<Memory>();
  }

  void scan() {
    float distSq = 0;
    for (Asteroid asteroid : asteroids) {
      distSq = PVector.sub(asteroid.position, position).magSq();
      if (distSq<=sq(64)) { //Mark any new astroids found.
        if (!memory.stream().anyMatch(Memory->Memory.position==asteroid.position)) {
          memory.add(new Memory(asteroid.position, true));
        }
        if (mode == 0) {
          modeControl(3);
        }
      }
      if (distSq<=sq(asteroid.size+16) && mode == 1) { //In mining mode, approach and mine the asteroid.
        cargo = true;
        asteroid.reduce();
        if (asteroid.size < 4) {
          emptyMark.set(asteroid.position.copy());
          memory.removeIf(Memory->PVector.sub(Memory.position,asteroid.position).magSq()==0);
        }
        modeControl(2);
        return;
      }
    }
  }

  void stationInteract() {
    if (cargo == true) { //Deposit any held cargo.
      cargo = false;
      home.stores += 1;
    }
    for (Memory entry : memory) { //Shares ship memory with the station.
      if (entry.firstHand == true && !home.sharedMemory.contains(entry.position)) {
        home.sharedMemory.add(entry.position); //The idea here is that a ship should not save a position that it has not confirmed.
      }
    }
    home.sharedMemory.remove(emptyMark); //Clear outdated marks in the station memory.
    emptyMark.set(-1, -1); //Reset the emptyMark.
    for (PVector entry : home.sharedMemory) { //Shares station memory with the ship.
      if (!memory.stream().anyMatch(Memory->PVector.sub(Memory.position,entry).magSq()==0)) {
        memory.add(new Memory(entry, false));
      }
    }
    if (mode == 2) { //If on return mode, switch back to scouting mode.
      brake = true;
      modeControl(0);
    }
  }

  void compute() {
    if (PVector.sub(target, position).magSq() < sq(16)) {
      brake = true;
    } else {
      brake = false;
    }

    scan();

    if (PVector.sub(home.position, position).magSq() < sq(40)) { //Station Interaction.
      stationInteract();
    }

    if (PVector.sub(target, position).magSq() < sq(8)) { //If the target location has nothing.
      memory.removeIf(Memory->PVector.sub(Memory.position,target).magSq()==0);
      emptyMark.set(target.copy());
      if (mode == 1 || mode == 0) {
        modeControl(2);
      } else {
        modeControl(-1);
      }
      return;
    }
    acceleration.add(PVector.sub(target, position).normalize().mult(0.25));
  }

  void modeControl(int setMode) { //Updates the target and color based on the mode.
    if (setMode == 3) { //modeControl(3) is a weighted random between mode 0 and mode 1.
      float mChance = float(memory.size())/asteroids.size(); // the higher the number, the greater % of asteroids are known.
      if (random(1) < mChance) {
        mode = 1;
      } else {
        mode = 0;
      }
    } else if (setMode != -1) { //modeControl(-1) updates the information without changing the current mode.
      mode = setMode;
    }   
    switch (mode) {
    case 0:
      target.set(random(16, fieldWidth-16), random(16, fieldHeight-16));
      bodyColor = color(255);
      break;
    case 1:
      target.set(memory.get(int(random(0, memory.size()))).position);
      bodyColor = color(48, 48, 255);
      break;
    case 2:
      target.set(home.position);
      bodyColor = color(48, 255, 48);
      break;
    }
  }

  void renderAI() { //Render override to add in AI information.
    render();
    if (selected == true) {
      strokeWeight(rScale);
      stroke(255, 255, 0);
      fill(255, 255, 0);
      line((position.x+rOffsetX)*rScale, (position.y+rOffsetY)*rScale, (target.x+rOffsetX)*rScale, (target.y+rOffsetY)*rScale);
      textAlign(CENTER, TOP);
      textSize(8*rScale);
      text("Brake="+brake+"\nMode="+mode, (position.x+rOffsetX)*rScale, (position.y+rOffsetY+16)*rScale);
      noFill();
      for (Memory entry : memory) {
        if (entry.firstHand == true) {
          stroke(255, 255, 0);
        } else {
          stroke(255, 128, 0);
        }
        circle((entry.position.x+rOffsetX)*rScale, (entry.position.y+rOffsetY)*rScale, 16*rScale);
      }
    }
  }
}
