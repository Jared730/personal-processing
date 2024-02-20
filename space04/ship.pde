class Ship {
  protected PVector position; //Measured in pixels across fieldWidth and fieldHeight.
  private PVector velocity; //Measured in pixels/frame.
  protected PVector acceleration; //Measured in pixels/frame^2 (I think?). Basically equivalent to force, since the mass of every ship is the same. Public, as this is the input parameter to move the ship.
  
  private float angle; //Used by the renderer, altered when speed != 0.
  private PShape body; //The shape used for rendering the ship. (Note: ship can be described by a circle with radius of 12, or a 16 by 16 box centered on the ship.)
  protected color bodyColor;

  protected boolean brake; //If on, attempt to reduce velocity.
  protected boolean cargo; //Carrying cargo if on.
  public boolean selected; //Debug selector. Public as this is an externally activated debug tool that only affects rendering.

  Ship() { //Constructor
    body = createShipBody();
    bodyColor = color(255);
    position = new PVector();
    velocity = new PVector(0, 0);
    angle = 0;
    acceleration = PVector.random2D();
    brake = false;
    cargo = false;
    selected = false;
  }

  void edgeCol() { //Bounce off edge.
    PVector dir = new PVector(0, 0);
    if (sq(position.x-fieldWidth/2) > sq(fieldWidth/2-16)) {
      dir.add(fieldWidth/2-position.x, 0);
    }
    if (sq(position.y-fieldHeight/2) > sq(fieldHeight/2-16)) {
      dir.add(0, fieldHeight/2-position.y);
    }
    acceleration.add(dir.normalize().mult(0.5));
  }
  
  void asteroidCol() { //Don't hit asteroids
    PVector difference = new PVector(0,0);
    for (Asteroid asteroid : asteroids) {
      difference.set(PVector.sub(position, asteroid.position));
      if (difference.magSq() <= sq(asteroid.size+8)) {
        acceleration.add(difference.normalize().mult(0.25));
      }
    }
  }
  
  void update() { //Runs all of the calculations of the ships position.
    if (brake == true) { //Adds acceleration based on the inertial brakes.
      if (velocity.magSq() >= 0.5) {
        acceleration.add(velocity.copy().normalize().mult(-0.5));
      } else {
        acceleration.add(velocity.copy().mult(-1));
      }
    }
    edgeCol(); //Adds acceleration based on border collision.
    asteroidCol(); //Adds acceleration based on asteroid collision.

    acceleration.limit(1).mult(0.5);
    velocity.add(acceleration).limit(2);
    if (velocity.magSq() > 0) {
      angle = velocity.heading();
    }
    position.add(velocity);
  }

  void render() { //Actually draws the ship
    body.resetMatrix();
    body.scale(rScale);
    body.rotate(angle);
    body.setFill(bodyColor);
    if (selected == true) {
      body.setStroke(color(255,255,0));
    } else if (brake == true) {
      body.setStroke(color(255,0,0));
    } else {
      body.setStroke(color(0));
    }
    shape(body, (position.x+rOffsetX)*rScale, (position.y+rOffsetY)*rScale);
    if (cargo == true) {
      fill(128);
      stroke(0);
      circle((position.x-12*cos(angle)+rOffsetX)*rScale, (position.y-12*sin(angle)+rOffsetY)*rScale, 12*rScale);
    }
    acceleration.set(0, 0);
  }
}
