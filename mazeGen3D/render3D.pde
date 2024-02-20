void drawTile3D(int x, int y, byte tile) {
  noStroke();
  pushMatrix();
  translate(x*16,y*16);
  fill(224);
  rect(0,0,16,16);
  fill(32);
  translate(-4,-4);
  box(8);
  translate(16,0);
  box(8);
  translate(0,16);
  box(8);
  translate(-16,0);
  box(8);
  translate(16,-8);
  if ((tile & 0x01) != 0x01) box(8);
  translate(-8,-8);
  if ((tile & 0x02) != 0x02) box(8);
  translate(-8,8);
  if ((tile & 0x04) != 0x04) box(8);
  translate(8,8);
  if ((tile & 0x08) != 0x08) box(8);
  translate(0,-8);
  if ((tile & 0x0F) == 0x00) box(8);
  popMatrix();
}

void drawMaze3D(Maze maze) {
  for (int y = 0; y < maze.mHeight; y++) {
    for (int x = 0; x < maze.mWidth; x++) {
      drawTile3D(x,y,maze.getTile(x,y));
    } 
  }
}
