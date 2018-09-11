//-------------------------------------- Monitor_MK ---------------------------------------------------------------------
public class Monitor_MK {
    private int[][] MK;

    public synchronized void write_MK(int[][] MK) {
        this.MK = MK;
    }

    public synchronized int[][] copy_MK() {
        return Data.copyMatrix(MK);
    }
}