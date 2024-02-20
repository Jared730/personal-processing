import java.util.Set;
import java.util.HashSet;
import java.util.SortedMap;
import java.util.TreeMap;

import java.io.FileOutputStream;

public class Lattice {
  public final int lWidth, lHeight, radius;
  public boolean full; //Invariant to indicate when no more nodes can be added (when addNode will always fail.)
  SortedMap<Coordinate, Crystal> nodeGrid; //I'll be honest it probably would make more sense to use a HashMap since the order shouldn't matter, IDK why I did this initially.
  Set<Crystal> crystals;
  SortedMap<Coordinate, Crystal> slotGrid;

  public Lattice(int w, int h, int r) { //Takes in the field width, field height, and node radius.
    full = false;
    crystals = new HashSet<>(24);
    nodeGrid = new TreeMap<>();
    slotGrid = new TreeMap<>();
    lWidth = w;
    lHeight = h;
    radius = r;
  }

  public void render() { //Renders all nodes registered to nodeGrid.
    for (Coordinate c : nodeGrid.keySet()) {
      renderNode(c);
    }
  }

  private void renderNode(Coordinate c) { //Renders the node at a given coordinate to the screen.
    Crystal k = nodeGrid.get(c);
    if (k == null) return; //Null return check.
    fill(k.nodeFill);
    stroke(k.nodeStroke);
    circle(radius+radius*c.x, 1.25*radius+radius*c.y-radius*c.x/2, radius);
  }

  public boolean addNode(Coordinate c, Crystal k) { //Attempts to add a node at position c to crystal k. Will return true if successful, will return false if there is no such valid open posiiton.
    if (nodeGrid.containsKey(c)) return false;
    if (c.x < 0 || c.x >= lWidth || c.y-c.x/2 < 0 || c.y-c.x/2 >= lHeight) return false;
    nodeGrid.put(c, k); //Register new node.
    slotGrid.remove(c);
    return true;
  }

  public void growCrystals() { //Each time this runs, a node is randomly added to one of the crystals, while attmepting to hold to Zipf's Law (a pareto distribution).
    if (full) return;
    Coordinate[] slotArray = (Coordinate[]) slotGrid.keySet().toArray(new Coordinate[slotGrid.size()]);
    int rand = int(random(0, slotArray.length));
    slotGrid.get(slotArray[rand]).addNode(slotArray[rand]);
    if (nodeGrid.size() >= lWidth * lHeight) {
      full = true;
    }
  }

  public void addCrystal() { //Adds a single crystal seed to the lattice.
    int rX = int(random(lWidth));
    int rY = int(rX/2+random(lHeight));
    crystals.add(new Crystal(rX, rY, this, int(random(360))));
  }

  public void addCrystal(int number) { //Adds any number of crystal seeds to the lattice.
    for (int i = 0; i < number; i++) {
      int rX = int(random(lWidth));
      int rY = int(rX/2+random(lHeight));
      crystals.add(new Crystal(rX, rY, this, int(360*float(i)/number)));
    }
  }

  void calcStats() throws IOException {
    Crystal[] cArray = (Crystal[]) crystals.toArray(new Crystal[crystals.size()]);
    int[] counter = new int[crystals.size()];
    for (Coordinate c : nodeGrid.keySet()) {
      Crystal k = nodeGrid.get(c);
      for (int i = 0; i < cArray.length; i++) {
        if (cArray[i] == k) counter[i]++;
      }
    }
    println("Crystal Sizes:");
    for (int i = 0; i < cArray.length; i++) {
      println((i+1)+": "+counter[i]);
    }
    counter = sort(counter); //TODO: fix writer so it appends data.txt instead of overwriting it.
    PrintWriter data = new PrintWriter(new FileOutputStream("C:/Users/jared/Documents/Processing/Tectonic3_Pareto/data_24.txt", true));
    for (int c = 0; c < counter.length-1; c++) {
      data.print(counter[c]+"\t");
    }
    data.println(counter[counter.length-1]);
    data.flush();
    data.close();
  }
}
