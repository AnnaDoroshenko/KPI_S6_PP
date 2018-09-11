/**
* Programming for Parallel Computer Systems
* Lab 3. C#. Semaphores, Mutexes, Events, Critical Sections
*
* A = sort(Z) * d + e * T * (MO * MK)
*
* Author: Anna Doroshenko
* Group: IO-52
* Date: 21.03.2018
*/

using System;
using System.Threading;

namespace Lab03
{
    class Lab03
    {
        private static readonly int N = 6;
        private static readonly int P = 6;
        private static readonly int H = N / P;

        static void Main(string[] args)
        {
            Console.WriteLine("Lab03 started");
           
            Data data = new Data(N);            
            Threads t = new Threads(data, N, P, H);

            Thread t1 = new Thread(t.T1);
            Thread t2 = new Thread(t.T2);
            Thread t3 = new Thread(t.T3);
            Thread t4 = new Thread(t.T4);
            Thread t5 = new Thread(t.T5);
            Thread t6 = new Thread(t.T6);

            t1.Name = "Thread 1";
            t1.Priority = ThreadPriority.AboveNormal;
            t2.Name = "Thread 2";
            t2.Priority = ThreadPriority.Highest;
            t3.Name = "Thread 3";
            t3.Priority = ThreadPriority.Normal;
            t4.Name = "Thread 4";
            t4.Priority = ThreadPriority.BelowNormal;
            t5.Name = "Thread 5";
            t5.Priority = ThreadPriority.Lowest;
            t6.Name = "Thread 6";
            t6.Priority = ThreadPriority.Normal;
           
            t1.Start();
            t2.Start();
            t3.Start();
            t4.Start();
            t5.Start();
            t6.Start();
            
            t1.Join();
            t2.Join();
            t3.Join();
            t4.Join();
            t5.Join();
            t6.Join();
            
            Console.WriteLine("Lab03 finished");
            Console.ReadKey();
        }
    }
}
