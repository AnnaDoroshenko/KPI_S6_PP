/**
 * Programming for Parallel Computer Systems
 * Lab 6. Java. Monitors
 *
 * A = d*Z + (B*C) * E * (MO*MK)
 *
 * @author: Anna Doroshenko
 * @group: IO-52
 * @date: 24.04.18
 */

import java.util.concurrent.RecursiveAction;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.ForkJoinTask;
import java.util.List;
import java.util.ArrayList;

public class Lab06 {
    private final static int N = 6;
    private final static int P = 6;
    private final static int H = N / P;

    private static ForkJoinPool pool = new ForkJoinPool(P);

    private int d;
    private int[] A = new int[N];
    private int[] Z = new int[N];
    private int[] B = new int[N];
    private int[] C = new int[N];
    private int[] E = new int[N];
    private int[][] MO = new int[N][N];
    private int[][] MK = new int[N][N];

    // --- Monitors  --
    private MonitorInput monitorInput = new MonitorInput();
    private MonitorOutput monitorOutput = new MonitorOutput();
    private Monitor_a monitor_a = new Monitor_a();
    private Monitor_d monitor_d = new Monitor_d();
    private Monitor_E monitor_E = new Monitor_E();
    private Monitor_MK monitor_MK = new Monitor_MK();

    public static void main(String[] args) {
        System.out.println("Lab06 started");
        new Lab06();
        System.out.println("Lab06 finished");
    }

    public Lab06(){
        pool.invoke(new Thread(1, 0, N));
    }

    public class Thread extends RecursiveAction {
        private int tid;
        private int st;
        private int fin;
        private Data data = new Data(N);

        public Thread(int tid, int st, int fin) {
            this.tid = tid;
            this.st = st;
            this.fin = fin;
        }

        @Override
        protected void compute() {
            if (fin - st == H) {
                process();
            } else {
                List<Thread> threads = new ArrayList<>();

                threads.add(new Thread(tid, st, st + H));
                threads.add(new Thread(tid + 1, st + H, fin));

                ForkJoinTask.invokeAll(threads);
            }
        }

        private void process() {
            System.out.println("Thread" + tid + " started");

            //input of data
            switch (tid) {
                case 1:
                    //input of Z and MO
                    data.fillVectorWithOnes(Z);
                    data.fillMatrixWithOnes(MO);
                    //signal about input of Z and MO
                    monitorInput.signalInput();
                    break;
                case 3:
                    //input of d, B, MK
                    d = 1;
                    monitor_d.write_d(d);
                    data.fillVectorWithOnes(B);
                    data.fillMatrixWithOnes(MK);
                    monitor_MK.write_MK(MK);
                    //signal about input of d, B, MK
                    monitorInput.signalInput();
                    break;
                case 4:
                    //input of C, E
                    data.fillVectorWithOnes(C);
                    data.fillVectorWithOnes(E);
                    monitor_E.write_E(E);
                    //signal about input of C, E
                    monitorInput.signalInput();
                    break;
                default:
                    break;
            }

            //wait for input of data in T1, T3, T4
            monitorInput.waitInput();

            //ai = Bh * Ch
            int ai = data. multVectorsH(B, C, st, fin);

            //a = a + a1
            monitor_a.calculation_a(ai);

            //signal about calculation of a
            monitor_a.signal_calc_a();

            //wait for calculation a in other tasks
            monitor_a.wait_a();

            //copy a, d, E and MK
            ai = monitor_a.copy_a();
            int di = monitor_d.copy_d();
            int[] Ei = monitor_E.copy_E();
            int[][] MKi = monitor_MK.copy_MK();

            //main calculations
            data.addVectors(A, data.multScalarVectorH(di, Z, st, fin),
                    data.multScalarVectorH(ai, data.multVectorMatrix(Ei,
                            data.multMatricesH(MO, MKi, st, fin), st, fin), st, fin), st, fin);

            if (tid == 1) {
                monitorOutput.waitOutput();

                if (N < 20) {
                    data.outputVector(A);
                }
            } else {
                monitorOutput.signalOutput();
            }

            System.out.println("Thread" + tid + " finished");
        }
    }
}
