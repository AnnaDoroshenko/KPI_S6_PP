//-------------------------------------- MonitorInput ---------------------------------------------------------------------
public class MonitorInput {
    private int F1 = 0;

    public synchronized void signalInput() {
        F1++;
        if (F1 == 3) {
            notifyAll();
        }
    }

    public synchronized void waitInput() {
        try {
            while (F1 != 3) {
                wait();
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
