static final byte RT = 0x1; //0001 //<>//
static final byte UT = 0x2; //0010
static final byte LT = 0x4; //0100
static final byte DT = 0x8; //1000

import java.util.HashSet;
import java.util.HashMap;

class Maze {
  int mWidth, mHeight;
  byte[][] field;
  HashSet<PVector> tileQueue;
  
  Maze(int w, int h) {
    mWidth = w;
    mHeight = h;
    field = new byte[mWidth][mHeight];
    for (int y = 0; y < mHeight; y++) {
      for (int x = 0; x < mWidth; x++) {
        field[x][y] = (byte)-128; // 10000000
      }
    }
    tileQueue = new HashSet<PVector>();
  }

  byte getTile(int x, int y) {
    if (x < 0 || x >= mWidth || y < 0 || y >= mHeight) return 0; //Return 0000 if invalid to mark tile as inaccessible.
    
    return field[x][y];
  }
  
  void setTile(int x, int y, byte tile) {
    if (x < 0 || x >= mWidth || y < 0 || y >= mHeight) return;
    field[x][y] = tile;
  }

  byte getCondition(int x, int y) { //First 4 bits state whether that side exists yet, other 4 bits state whether that side is open or not.
    byte condition = 0;

    if (getTile(x+1, y) < 0) condition |= RT << 4; //Check tile to the right
    else if ((getTile(x+1, y) & LT) == LT) condition |= RT;

    if (getTile(x, y-1) < 0) condition |= UT << 4; //Check tile above
    else if ((getTile(x, y-1) & DT) == DT) condition |= UT;

    if (getTile(x-1, y) < 0) condition |= LT << 4; //Check tile to the left
    else if ((getTile(x-1, y) & RT) == RT) condition |= LT;

    if (getTile(x, y+1) < 0) condition |= DT << 4; //Check tile below
    else if ((getTile(x, y+1) & UT) == UT) condition |= DT;
    return condition;
  }

  boolean isValid(int x, int y, byte tile) {
    byte condition = getCondition(x, y); //Grab condition.
    if (condition < 0) {
      if (tile == 0) return false;
      if (tile == 1 || tile == 2 || tile == 4 || tile == 8) {
        if ((condition & 0x0F) == 0) return true; //Do allow a dead end if the tile is not starting from a queue point.
        return false; //Do not allow cutoffs unless this is a true dead end.
      }
    }
    tile ^= condition; //XOR tile and condition.
    tile ^= 0xFF; //Invert tile. I don't trust the downcasting but I have no choice as since NOT is unary it has no assignment operator.
    tile &= 15; //Dump the leading 4 bits.
    tile |= ((condition >> 4) & 0x0F); //OR in the leading condition bits. //Why is this not working?
    return (tile == 15); //return true if now tile == 15.
  }

  void generateTile(int x, int y) {
    ArrayList<Byte> validTiles = new ArrayList<Byte>();
    for (byte i = 0; i < 16; i++) {
      if (isValid(x, y, i)) validTiles.add(Byte.valueOf(i)); //If this possible configuration is allowed, add it to the list.
      /* Not a great solution - causes a lot of cut-off mazes.
      if (i == 3 || i == 5 || i == 6 || i == 9 || i == 10 ||i == 12) { //Spaghettify maze - Bias towards tiles with 2 joints.
        if (isValid(x, y, i)) validTiles.add(Byte.valueOf(i));
      }
      */
    }
    if (validTiles.size() == 0) {
      println("Error: No possible valid tile at ("+x+","+y+").");
      tileQueue.remove(new PVector(x, y));
      return;
    }
    byte randTile = validTiles.get(int(random(validTiles.size()))).byteValue();
    setTile(x, y, randTile);
    tileQueue.remove(new PVector(x, y));
    if ((randTile & RT) == RT && getTile(x+1, y) < 0) tileQueue.add(new PVector(x+1, y)); //Adds the adjacent tiles to the queue if necessary.
    if ((randTile & UT) == UT && getTile(x, y-1) < 0) tileQueue.add(new PVector(x, y-1)); //Two's compliment dictates that if the tile has a leading 1 then it is negative.
    if ((randTile & LT) == LT && getTile(x-1, y) < 0) tileQueue.add(new PVector(x-1, y));
    if ((randTile & DT) == DT && getTile(x, y+1) < 0) tileQueue.add(new PVector(x, y+1));
  }

  void growMaze() {
    HashSet<PVector> oldQueue = new HashSet<PVector>(tileQueue);
    for (PVector qPos : oldQueue) {
      generateTile(int(qPos.x), int(qPos.y));
    }
  }
  
  void fillMaze() {
    generateTile(int(random(mWidth)),int(random(mHeight)));
    println("Generating Maze...");
    int gCount = 0;
    while (tileQueue.size() > 0) {
      growMaze();
      gCount++;
    }
    println("Maze Generation complete after "+gCount+" iterations.");
  }
  
  void overwriteTile(int x, int y) {
    byte oldTile = getTile(x,y);
    oldTile &= 0x0F;
    if ((oldTile & 0x0F) == 0x0F) oldTile = 0;
    else oldTile += 1;
    setTile(x,y, oldTile);
    tileQueue.add(new PVector(x+1, y));
    tileQueue.add(new PVector(x, y-1));
    tileQueue.add(new PVector(x-1, y));
    tileQueue.add(new PVector(x, y+1));
    tileQueue.remove(new PVector(x,y));
    println("New tile at ("+x+","+y+"): "+binary(oldTile));
  }
  
  void countTiles() {
    int nTiles = 0;
    int eTiles = 0;
    int sTiles = 0;
    int cTiles = 0;
    int tTiles = 0;
    int xTiles = 0;
    int tileCount = 0;
    for (int y = 0; y < mHeight; y++) {
      for (int x = 0; x < mWidth; x++) {
        byte tile = getTile(x,y);
        if (tile < 0) continue; //Don't count undetermined tiles
        if (tile == 15) xTiles++;
        else if (tile == 14 || tile == 13 || tile == 11 || tile == 7) tTiles++;
        else if (tile == 12 || tile == 9 || tile == 6 || tile == 3) cTiles++;
        else if (tile == 10 || tile == 5) sTiles++;
        else if (tile == 8 || tile == 4 || tile == 2 || tile == 1) eTiles++;
        else nTiles++;
        tileCount++;
      }
    }
    println("Tile Count:");
    println("- Null Tiles: "+nTiles);
    println("- End Tiles: "+eTiles);
    println("- Straight Tiles: "+sTiles);
    println("- Corner Tiles: "+cTiles);
    println("- T Junction Tiles: "+tTiles);
    println("- X Junction Tiles: "+xTiles);
    println("For a total of "+tileCount+" tiles total.");
    println("Grid usage = "+float(tileCount)/(mWidth*mHeight)*100+"%.");
  }
}
