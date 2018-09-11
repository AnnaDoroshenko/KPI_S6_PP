//-------------------------------------- Monitor_E ---------------------------------------------------------------------
public class Monitor_E {
    private int[] E;

    public synchronized void write_E(int[] E) {
        this.E = E;
    }

    public synchronized int[] copy_E() {
        return Data.copyVector(E);
    }
}
