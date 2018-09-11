//-------------------------------------- MonitorOutput ---------------------------------------------------------------------
public class MonitorOutput {
    private int F2 = 0;

    public synchronized void signalOutput() {
        F2++;
        if (F2 == 5) {
            notifyAll();
        }
    }

    public synchronized void waitOutput() {
        try {
            while (F2 != 5) {
                wait();
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
