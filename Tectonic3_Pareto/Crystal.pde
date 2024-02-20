//Class to represent a single crystal in the lattice.
public class Crystal {
  private final Lattice lattice; //Reference to parent lattice
  public final color nodeFill, nodeStroke;

  public Crystal(int x, int y, Lattice lat, int hue) {
    lattice = lat;
    nodeFill = color(hue, 100, 100);
    nodeStroke = color(hue, 80, 70);
    addNode(new Coordinate(x, y));
  }

  public void addNode(Coordinate c) { //Helper method to encapsulate the adding of the node and its adjacent slots to the lattice.
    if (!lattice.addNode(c, this)) return; //Failed to add node.
    addSlot(c.x+1, c.y+1);
    addSlot(c.x, c.y+1);
    addSlot(c.x+1, c.y);
    addSlot(c.x-1, c.y-1);
    addSlot(c.x, c.y-1);
    addSlot(c.x-1, c.y);
  }

  private void addSlot(int x, int y) { //Tries to mark adjacent open coordinates to the newly added node as available.
    Coordinate c = new Coordinate(x, y);
    if (!lattice.nodeGrid.containsKey(c)) lattice.slotGrid.putIfAbsent(c, this);
  }
}
