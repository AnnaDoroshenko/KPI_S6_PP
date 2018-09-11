//-------------------------------------- Monitor_d ---------------------------------------------------------------------
public class Monitor_d {
    private int d;

    public synchronized void write_d(int d) {
        this.d = d;
    }

    public synchronized int copy_d() {
        return d;
    }
}
