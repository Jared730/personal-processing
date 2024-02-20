//Simple data structure to store an integer coordinate. This has no override of the hashing method, so be careful using this for a hashMap or hashSet.
public class Coordinate implements Comparable<Coordinate> { 
  public int x;
  public int y;

  public Coordinate(int x, int y) {
    this.x = x;
    this.y = y;
  }

  @Override
    public boolean equals(Object obj) {
    if (obj instanceof Coordinate) {
      return ((Coordinate)obj).x == x && ((Coordinate)obj).y == y;
    }
    return false;
  }

  @Override
    public int compareTo(Coordinate other) {
    int out = Integer.signum(y-other.y);
    if (out == 0) {
      out = Integer.signum(x-other.x);
    }
    return out;
  }
}
