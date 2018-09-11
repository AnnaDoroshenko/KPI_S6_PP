//-------------------------------------- Monitor_a ---------------------------------------------------------------------
public class Monitor_a {
    private int F3 = 0;
    private int a = 0;

    public synchronized void signal_calc_a() {
        F3++;
        if (F3 == 6) {
            notifyAll();
        }
    }

    public synchronized void wait_a() {
        try {
            while (F3 != 6) {
                wait();
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public synchronized void calculation_a(int ai) {
        a += ai;
    }

    public synchronized int copy_a() {
        return a;
    }
}
