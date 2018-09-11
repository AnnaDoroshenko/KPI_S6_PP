--------------------------------------------------------------------------------
-- Programming for Parallel Computer Systems --
-- Lab 1. Ada. Semaphores --

-- MO:=min(Z)*MT*MR+alpha*MU --

-- Author: Anna Doroshenko --
-- Group: IO-52 --
-- Date: 21.02.2018 --
--------------------------------------------------------------------------------

with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

procedure Lab01 is

   Storage : Integer := 50000000;
   N : Integer := 4;             -- size of the vector and the matrix
   P : Integer := 2;             -- amount of the processors
   H : Integer := N/P;           -- size of the subvector and the submatrix

   package NewData is new Data(N);
   use NewData;

   -- common resourses --
   a : Integer := 2147483647;     -- var for min (now have value of max integer)
   alpha : Integer;
   MT : Matrix;

   MO, MR, MU : Matrix;
   Z : Vector;
   S00, S0, S1, S2, S3, S4, S5 : Suspension_Object;

   procedure Task_Launch is

   -- Specification of task 1 --
   task T1 is
      pragma Task_Name("Task 1");
      pragma Storage_Size(Storage);
   end T1;

   -- Specification of task 2 --
   task T2 is
      pragma Task_Name("Task 2");
      pragma Storage_Size(Storage);
   end T2;

   -----------------------------------------------------------------------------
   -- Body of task 1 --
   task body T1 is
      alpha1, a1 : Integer;
      MT1 : Matrix;
   begin
      Put_Line("Task T1 started");

      -- input of Z and MR
      FillVectorWithOnes(Z);
      FillMatrixWithOnes(MR);

      -- signal T2 about input of Z and MR
      Set_True(S1);

      -- wait for input of data in T2
      Suspend_Until_True(S2);

      -- calculation of a1 := min(Zh)
      a1 := SearchMinElemOfVectH(Z, 1, H);

      -- calculation of a := min(a; a1)
      -- critical section
      Suspend_Until_True(S00);
         a := SearchMin(a, a1);
      Set_True(S00);

      -- signal T2 about end of min calculation part
      Set_True(S3);

       -- wait for the end of min calculation part in T2
      Suspend_Until_True(S4);

      -- copy alpha, a and MT
      -- critical section
      Suspend_Until_True(S0);
         alpha1 := alpha;
         a1 := a;
         MT1 := CopyMatrix(MT);
      Set_True(S0);

      -- main calculations
      AddMatricesH(MO, MultScalarMatrixH(a1, MultMatricesH(MT1, MR, 1, H), 1, H),
                   MultScalarMatrixH(alpha1, MU, 1, H), 1, H);

      -- wait for calculations end in T2
      Suspend_Until_True(S5);

      -- output
      if (N < 5) then
         Put_Line("Result: ");
         OutputMatrix(MO);
         New_Line;
      end if;

      Put_Line("Task T1 finished");

   end T1;

  ------------------------------------------------------------------------------
  -- Body of task 2 --
   task body T2 is
      alpha2, a2 : Integer;
      MT2: Matrix;
   begin
      Put_Line("Task T2 started");

      -- input of MT, alpha and MU
      alpha := 1;
      FillMatrixWithOnes(MT);
      FillMatrixWithOnes(MU);

      -- signal T1 about input of MT, alpha and MU
      Set_True(S2);

      -- wait for input of data in T1
      Suspend_Until_True(S1);

      -- calculation of a2 := min(Zh)
      a2 := SearchMinElemOfVectH(Z, H+1, N);

      -- calculation of a := min(a; a2)
      -- critical section
      Suspend_Until_True(S00);
         a := SearchMin(a, a2);
      Set_True(S00);

      -- signal T1 about end of min calculation part
      Set_True(S4);

      -- wait for the end of min calculation part in T1
      Suspend_Until_True(S3);

      -- copy alpha, a and MT
      -- critical section
      Suspend_Until_True(S0);
         alpha2 := alpha;
         a2 := a;
         MT2 := CopyMatrix(MT);
      Set_True(S0);

      -- main calculations
      AddMatricesH(MO, MultScalarMatrixH(a2, MultMatricesH(MT2, MR, H+1, N), H+1, N),
                   MultScalarMatrixH(alpha2, MU, H+1, N), H+1, N);

      -- signal T1 about end of calculations
      Set_True(S5);

      Put_Line("Task T2 finished");

      end T2;

   begin
      null;
   end Task_Launch;

-- Body of main programme
begin
   Put_Line("Lab01 started");
   Set_True(S0);
   Set_True(S00);
   Task_Launch;
   Put_Line("Lab01 finished");
end Lab01;
