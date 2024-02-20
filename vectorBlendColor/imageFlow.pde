//All recursive flow experiments are in here - seeing what happens when an image is distorted by the dirField that vectorBlend produces.

void createNoise() {
  if (noiseMap == null) noiseMap = createImage(width, height, RGB);
  noiseMap.loadPixels();
  colorMode(HSB);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      PVector delta = interpVector(x,y);
      noiseMap.pixels[y*width+x] = color(int(delta.heading()*(127.5/PI)+127),255,255);
    }
  }
  colorMode(RGB);
  noiseMap.updatePixels();
}

void createStatic() {
  noiseMap.loadPixels();
  colorMode(HSB);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      noiseMap.pixels[y*width+x] = color(int(random(256)),255,255);
    }
  }
  colorMode(RGB);
  noiseMap.updatePixels();
}

int getNoise(int x, int y) {
  while (x < 0) x += width;
  while (y < 0) y += height;
  x %= width;
  y %= height;
  noiseMap.loadPixels();
  return noiseMap.pixels[y*width+x];
}

PVector interpVector(float x, float y) { //2D linear mapping, because 2D cubic mapping would be very expensive.
  PVector aa = getDir(floor(x/spacing),floor(y/spacing));
  PVector ab = getDir(floor(x/spacing),ceil(y/spacing));
  PVector ba = getDir(ceil(x/spacing),floor(y/spacing));
  PVector bb = getDir(ceil(x/spacing),ceil(y/spacing));
  PVector a = PVector.lerp(aa,ab,(y%spacing)/spacing);
  PVector b = PVector.lerp(ba,bb,(y%spacing)/spacing);
  return a.lerp(b,(x%spacing)/spacing);
}

void imageFlow() { //Static image flow
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      PVector delta = interpVector(x,y);
      pixels[y*width+x] = getNoise(round(x-delta.x*spacing),round(y-delta.y*spacing));
    }
  }
  updatePixels();
}

//Both Prograde and Retrograde Recursion can cause both pixel loss and pixel duplication, based on if the recieving/emmitting airstream is merging or splitting. 
//A split airstream can duplicate pixels, while a merged airstream can delete pixels. I have no way to ensure an even flow density, so this will always be an issue to some extent.

//Retrograde Recursive flow - steps backwards to estimate image shift. More implementation-friendly, but will lead to data loss as the motion of some pixels is unaccounted for.
void recursiveFlow() { 
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      PVector delta = interpVector(x,y);
      pixels[y*width+x] = getNoise(round((float)x-delta.x*2),round((float)y-delta.y*2));
    }
  }
  updatePixels();
  noiseMap.set(0,0,get());
}

//Prograde(Antegrade) Recursive Flow - Proactively steps pixels foward to manually shift image. This has some difficulty with blendstates so later pixels override earlier pixels.
void recursiveFlow2() {
  set(0,0,noiseMap);
  noiseMap.loadPixels();
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      PVector delta = interpVector(x,y);
      int dX = round((float)x + delta.x);
      int dY = round((float)y + delta.y);
      while (dX < 0) dX += width;
      while (dY < 0) dY += height;
      dX %= width;
      dY %= height;
      noiseMap.pixels[dY*width+dX] = pixels[y*width+x];
    }
  }
  noiseMap.updatePixels();
}

//Complementary Recursive Flow - Functionally the same as Retrograde Recursion, except that the pixels flow 90 degrees clockwise of the vector direction.
//Due to the natural tendency of the flow vectors to curl on themselves and form little eddies and vortexes, this cross-flow causes a lot of pixel loss and pixel duplication.
void complementFlow() { 
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      PVector delta = interpVector(x,y);
      pixels[y*width+x] = getNoise(round((float)x-delta.y*2),round((float)y+delta.x*2));
    }
  }
  updatePixels();
  noiseMap.set(0,0,get());
}
