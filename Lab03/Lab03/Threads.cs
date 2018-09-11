using System;
using System.Threading;

namespace Lab03
{
    class Threads
    {
        private int N;
        private int P;
        private int H;

        private volatile int d;
        private int e;
        private int[] T, A, Z;
        private int[,] MK, MO;

        //--- Semaphores ---
        private static Semaphore S1 = new Semaphore(0, 5);
        private static Semaphore S2 = new Semaphore(0, 5);
        private static Semaphore S3 = new Semaphore(0, 5);

        //--- Mutexes ---
        private static Mutex M1 = new Mutex(false);
        
        //--- Locks ---
        private static readonly object Lock1 = new object();

        //--- Events ---
        private static EventWaitHandle E0 = new EventWaitHandle(false, EventResetMode.ManualReset);
        private static EventWaitHandle E1 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E11 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E111 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E2 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E22 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E3 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E4 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E5 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E6 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E7 = new EventWaitHandle(false, EventResetMode.AutoReset);
        private static EventWaitHandle E8 = new EventWaitHandle(false, EventResetMode.AutoReset);

        //--- Monitors ---
        private static object Monitor1 = new object();

        private Data data;

        public Threads(Data data, int N, int P, int H)
        {
            this.data = data;
            this.N = N;
            this.P = P;
            this.H = H;

            T = new int[N];
            A = new int[N];
            Z = new int[N];
            MK = new int[N, N];
            MO = new int[N, N];
         }

        //----------------------------------------------------------------------------
        public void T1()
        {
            const int st = 0;
            int fin = H;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //input of d, e and MK
            d = 1;
            e = 1;
            data.FillMatrixWithOnes(ref MK);

            //signal T2, T3, T4, T5, T6 about input of d, e and MK
            S1.Release(5);
            
            //wait for input of data in T2, T4
            S2.WaitOne();
            S3.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);
            
            //wait for sort Zh part in T2 
            E1.WaitOne();
            
            //merge sort S12=sort*(Sh, Sh)
            data.SortMergeVector(ref Z, 0, 2 * H);

            //copy T
            M1.WaitOne();
            int[] T1 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //copy d, e
            //critical section
            int d1 = d;
            int e1;
            lock (Lock1)
            {
                e1 = e;
            }

            //copy MO
            int[,] MO1;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO1 = data.CopyMatrix(ref MO);
                } finally
                {
                    Monitor.Exit(Monitor1);
                }
            }
                        
            //wait for merge sort S3456=sort*(S34, S56) in T3
            E2.WaitOne();
            
            //merge sort S=sort*(S1, S3456)
            data.SortMergeVector(ref Z, 0, N);
            
            //signal T2, T3, T4, T5, T6 about end of total merge sort
            E0.Set();
           
            //main calculations
            int[] resultVector1 = data.MultScalarVector(d1, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO1, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T1, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e1, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //signal T4 about end of calculation
            E4.Set();
            
            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }

        //----------------------------------------------------------------------------
        public void T2()
        {
            int st = H;
            int fin = 2 * H;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //input of T and MO
            data.FillVectorWithOnes(ref T);
            data.FillMatrixWithOnes(ref MO);

            //signal T1, T3, T4, T5, T6 about input of T and MO
            S2.Release(5);
            
            //wait for input of data in T1, T4
            S1.WaitOne();
            S3.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);
            
            //signal T1 about end of sort Zh part
            E1.Set();

            //copy MO
            int[,] MO2;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO2 = data.CopyMatrix(ref MO);
                }
                finally
                {
                    Monitor.Exit(Monitor1);
                }
            }

            //copy d, e
            //critical section
            int d2 = d;
            int e2;
            lock (Lock1)
            {
                e2 = e;
            }

            //copy T
            M1.WaitOne();
            int[] T2 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //wait for end of total merge sort in T1
            E0.WaitOne();

            //main calculations
            int[] resultVector1 = data.MultScalarVector(d2, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO2, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T2, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e2, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //signal T4 about end of calculation
            E5.Set();

            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }

        //----------------------------------------------------------------------------
        public void T3()
        {
            int st = 2 * H;
            int fin = 3 * H;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //wait for input of data in T1, T2, T4
            S1.WaitOne();
            S2.WaitOne();
            S3.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);

            //wait for sort Zh part in T4 
            E11.WaitOne();
            
            //merge sort S34=sort*(Sh, Sh)
            data.SortMergeVector(ref Z, 2 * H, 4 * H);

            //copy T
            M1.WaitOne();
            int[] T3 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //copy d, e
            //critical section
            int d3 = d;
            int e3;
            lock (Lock1)
            {
                e3 = e;
            }

            //copy MO
            int[,] MO3;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO3 = data.CopyMatrix(ref MO);
                }
                finally
                {
                    Monitor.Exit(Monitor1);
                }
            }

            //wait for merge sort S56=sort*(Sh, Sh) in T5
            E22.WaitOne();

            //merge sort S3456=sort*(S34, S56)
            data.SortMergeVector(ref Z, 2 * H, N);

            //signal T1 about end of merge sort S3456=sort*(S34, S56)
            E2.Set();

            //wait for end of total merge sort in T1
            E0.WaitOne();

            //main calculations
            int[] resultVector1 = data.MultScalarVector(d3, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO3, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T3, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e3, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //signal T4 about end of calculation
            E6.Set();

            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }

        //----------------------------------------------------------------------------
        public void T4()
        {
            int st = 3 * H;
            int fin = 4 * H;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //input of Z
            data.FillVectorWithOnes(ref Z);
            data.SetDefaultVector(ref A);

            //signal T1, T2, T3, T5, T6 about input of Z
            S3.Release(5);
            
            //wait for input of data in T1, T2
            S1.WaitOne();
            S2.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);

            //signal T3 about end of sort Zh part
            E11.Set();

            //copy MO
            int[,] MO4;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO4 = data.CopyMatrix(ref MO);
                }
                finally
                {
                    Monitor.Exit(Monitor1);
                }
            }

            //copy d, e
            //critical section
            int d4 = d;
            int e4;
            lock (Lock1)
            {
                e4 = e;
            }

            //copy T
            M1.WaitOne();
            int[] T4 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //wait for end of total merge sort in T1
            E0.WaitOne();

            //main calculations
            int[] resultVector1 = data.MultScalarVector(d4, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO4, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T4, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e4, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //wait for calculations end in T1, T2 and T3 
            E4.WaitOne();
            E5.WaitOne();
            E6.WaitOne();
            E7.WaitOne();
            E8.WaitOne();

            //Output A
            data.OutputVector(ref A);

            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }

        //----------------------------------------------------------------------------
        public void T5()
        {
            int st = 4 * H;
            int fin = 5 * H;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //wait for input of data in T1, T2, T4
            S1.WaitOne();
            S2.WaitOne();
            S3.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);

            //wait for sort Zh part in T6 
            E111.WaitOne();

            //merge sort S56=sort*(Sh, Sh)
            data.SortMergeVector(ref Z, 4 * H, N);

            //signal T3 about end of merge sort S56=sort*(Sh, Sh)
            E22.Set();
            
            //copy T
            M1.WaitOne();
            int[] T5 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //copy d, e
            //critical section
            int d5 = d;
            int e5;
            lock (Lock1)
            {
                e5 = e;
            }

            //copy MO
            int[,] MO5;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO5 = data.CopyMatrix(ref MO);
                }
                finally
                {
                    Monitor.Exit(Monitor1);
                }
            }

            //wait for end of total merge sort in T1
            E0.WaitOne();

            //main calculations
            int[] resultVector1 = data.MultScalarVector(d5, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO5, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T5, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e5, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //signal T4 about end of calculation
            E7.Set();

            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }

        //----------------------------------------------------------------------------
        public void T6()
        {
            int st = 5 * H;
            int fin = N;

            Console.WriteLine(Thread.CurrentThread.Name + " started");

            //wait for input of data in T1, T2, T4
            S1.WaitOne();            
            S2.WaitOne();
            S3.WaitOne();
            
            //sort Zh
            data.SortVector(ref Z, st, fin);

            //signal T5 about end of sort Zh part
            E111.Set();

            //copy MO
            int[,] MO6;
            Monitor.Enter(Monitor1);
            {
                try
                {
                    MO6 = data.CopyMatrix(ref MO);
                }
                finally
                {
                    Monitor.Exit(Monitor1);
                }
            }

            //copy d, e
            //critical section
            int d6 = d;
            int e6;
            lock (Lock1)
            {
                e6 = e;
            }

            //copy T
            M1.WaitOne();
            int[] T6 = data.CopyVector(ref T);
            M1.ReleaseMutex();

            //wait for end of total merge sort in T1
            E0.WaitOne();

            //main calculations
            int[] resultVector1 = data.MultScalarVector(d6, ref Z, st, fin);
            int[,] multMatrixResult = data.MultMatrices(ref MO6, ref MK, st, fin);
            int[] multVecMatrixResult = data.MultVectorMatrix(ref T6, multMatrixResult, st, fin);
            int[] resultVector2 = data.MultScalarVector(e6, ref multVecMatrixResult, st, fin);

            data.AddVectors(ref A, ref resultVector1, ref resultVector2, st, fin);

            //signal T4 about end of calculation
            E8.Set();

            Console.WriteLine(Thread.CurrentThread.Name + " finished");
        }
     }
}