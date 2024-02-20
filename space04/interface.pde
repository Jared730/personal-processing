class Button {
  int x, y, hSize, vSize;
  boolean pressed;
  PShape buttonShape;
  Button(int nX,int nY,int nhSize,int nvSize) {
    x = nX;
    y = nY;
    hSize = nhSize;
    vSize = nvSize;
    strokeWeight(2);
    buttonShape = createShape(RECT, -hSize/2, -vSize/2, hSize, vSize, vSize/8);
    pressed = false;
  }
  
  void render() {
    buttonShape.resetMatrix();
    if (pressed == true) {
      buttonShape.setFill(color(224,224,128));
    } else {
      buttonShape.setFill(color(128));
    }
    shape(buttonShape, x, y);
  }
  
  boolean mOver() {
    if (abs(mouseX-x) <= hSize/2 && abs(mouseY-y) < vSize/2) {
      return true;
    }
    //println(abs(mouseX-x), abs(mouseY-y));
    return false;
  }
}

class PauseButton extends Button {
  PShape onShape, offShape;
  PauseButton(int nX,int nY,int nhSize,int nvSize) {
    super(nX, nY, nhSize, nvSize);
    createShapes();
  }
  
  void update() {
    render();
    if (pause == true) {
      shape(onShape,x,y,vSize/4,vSize/4);
    } else {
      shape(offShape,x,y,vSize/4,vSize/4);
    }
  }
  
  private void createShapes() {
    onShape = createShape();
    onShape.beginShape(TRIANGLES);
    onShape.fill(0);
    onShape.noStroke();
    onShape.vertex(4,0);
    onShape.vertex(-4,-4);
    onShape.vertex(-4,4);
    onShape.endShape();
    
    offShape = createShape();
    offShape.beginShape(QUADS);
    offShape.fill(0);
    offShape.noStroke();
    offShape.vertex(4,4);
    offShape.vertex(4,-4);
    offShape.vertex(1,-4);
    offShape.vertex(1,4);
    offShape.vertex(-4,4);
    offShape.vertex(-4,-4);
    offShape.vertex(-1,-4);
    offShape.vertex(-1,4);
    offShape.endShape();
  }
}
