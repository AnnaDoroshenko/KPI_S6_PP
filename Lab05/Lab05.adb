--------------------------------------------------------------------------------
-- Programming for Parallel Computer Systems --
-- Lab 5. Ada. Protected units --

-- A = d * Z + (B * C) * E * (MO * MK) --

-- Author: Anna Doroshenko --
-- Group: IO-52 --
-- Date: 18.04.2018 --
--------------------------------------------------------------------------------
with Data, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;

procedure Lab05 is

   Storage : Integer := 50000000;
   N : Integer := 3000;             -- size of the vector and the matrix
   P : Integer := 4;             -- amount of the processors
   H : Integer := N/P;           -- size of the subvector and the submatrix

   package NewData is new Data(N);
   use NewData;

   -- common resourses --
   d : Integer;
   E : Vector;
   MK : Matrix;

   VA, Z, B, C : Vector;
   MO: Matrix;

   -- protected unit BoxInput --
   protected BoxInput is
      procedure Signal_input;
      entry Wait_input;

      private
      	F1 : Natural := 0;
   end BoxInput;

   protected body BoxInput is
      procedure Signal_input is
      begin
      	F1 := F1 + 1;
      end Signal_input;

      entry Wait_input when F1 = 3 is
      begin
      	null;
      end Wait_input;
   end BoxInput;

   -- protected unit BoxOutput --
   protected BoxOutput is
      procedure Signal_output;
      entry Wait_output;

      private
      	F2 : Natural := 0;
   end BoxOutput;

   protected body BoxOutput is
      procedure Signal_output is
      begin
      	F2 := F2 + 1;
      end Signal_output;

      entry Wait_output when F2 = 3 is
      begin
      	null;
      end Wait_output;
   end BoxOutput;

   -- protected unit Box_a --
   protected Box_a is
      function Copy_a return Integer;
      procedure Calculation_a (ai: in Integer);
      procedure Signal_calc_a;
      entry Wait_a;

      private
      	F3 : Natural := 0;
      	a : Integer := 0;
   end Box_a;

   protected body Box_a is
      function Copy_a return Integer is
      begin
      	return a;
      end Copy_a;

      procedure Calculation_a (ai: in Integer) is
      begin
         a := a + ai;
      end Calculation_a;

      procedure Signal_calc_a is
      begin
      	F3 := F3 + 1;
      end Signal_calc_a;

      entry Wait_a when F3 = 4 is
      begin
      	null;
      end Wait_a;
   end Box_a;

   -- protected unit Box_d --
   protected Box_d is
      function Copy_d return Integer;
      procedure Write_d(dd : Integer);

      private
      	d : Integer;
   end Box_d;

   protected body Box_d is
      function Copy_d return Integer is
      begin
      	return d;
      end Copy_d;

      procedure Write_d(dd: in Integer) is
      begin
         d := dd;
      end Write_d;
   end Box_d;

   -- protected unit Box_E --
   protected Box_E is
      function Copy_E return Vector;
      procedure Write_E(VE : Vector);

      private
      	E : Vector;
   end Box_E;

   protected body Box_E is
      function Copy_E return Vector is
      begin
      	return E;
      end Copy_E;

      procedure Write_E(VE: in Vector) is
      begin
         for i in 1..N loop
            E(i) := VE(i);
         end loop;
      end Write_E;
   end Box_E;

   -- protected unit Box_MK --
   protected Box_MK is
      function Copy_MK return Matrix;
      procedure Write_MK(MA : Matrix);

      private
      	MK : Matrix;
   end Box_MK;

   protected body Box_MK is
      function Copy_MK return Matrix is
      begin
      	return MK;
      end Copy_MK;

      procedure Write_MK(MA: in Matrix) is
      begin
      	for i in 1..N loop
      		for j in 1..N loop
      			MK(i,j) := MA(i,j);
      		end loop;
         end loop;
      end Write_MK;
   end Box_MK;

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

   -- Specification of task 3 --
   task T3 is
      pragma Task_Name("Task 3");
      pragma Storage_Size(Storage);
      end T3;

   -- Specification of task 4 --
   task T4 is
      pragma Task_Name("Task 4");
      pragma Storage_Size(Storage);
   end T4;

   -----------------------------------------------------------------------------
   -- Body of task 1 --
   task body T1 is
      a1, d1 : Integer;
      E1 : Vector;
      MK1 : Matrix;
   begin
      Put_Line("Task T1 started");

      -- input of Z and MO
      FillVectorWithOnes(Z);
      FillMatrixWithOnes(MO);

      -- signal about input of Z and MO
      BoxInput.Signal_input;

      -- wait for input of data
      BoxInput.Wait_input;

      -- a1 = Bh * Ch
      a1 := MultVectorsH (B, C, 1, H);

      -- a = a + a1
      Box_a.Calculation_a(a1);

      -- signal about calculation of a
      Box_a.Signal_calc_a;

      -- wait for calculation a in other tasks
      Box_a.Wait_a;

      -- copy a, d, E and MK
      a1 := Box_a.Copy_a;
      d1 := Box_d.Copy_d;
      E1 := Box_E.Copy_E;
      MK1 := Box_MK.Copy_MK;

      -- main calculations
      AddVectorsH(VA, MultScalarVectorH(d1, Z, 1, H),
                  MultScalarVectorH(a1, MultVectorMatrix(E1,
                    MultMatricesH(MO, MK1, 1, H), 1, H), 1, H), 1, H);

      -- wait for calculations end
      BoxOutput.Wait_output;

      -- output
      if (N < 10) then
         Put_Line("Result: ");
         OutputVector(VA);
         New_Line;
      end if;

      Put_Line("Task T1 finished");
   end T1;

   -----------------------------------------------------------------------------
   -- Body of task 2 --
   task body T2 is
      a2, d2 : Integer;
      E2 : Vector;
      MK2 : Matrix;
   begin
      Put_Line("Task T2 started");

      -- wait for input of data
      BoxInput.Wait_input;

      -- a2 = Bh * Ch
      a2 := MultVectorsH (B, C, H+1, 2*H);

      -- a = a + a2
      Box_a.Calculation_a(a2);

      -- signal about calculation of a
      Box_a.Signal_calc_a;

      -- wait for calculation a in other tasks
      Box_a.Wait_a;

      -- copy a, d, E and MK
      a2 := Box_a.Copy_a;
      d2 := Box_d.Copy_d;
      E2 := Box_E.Copy_E;
      MK2 := Box_MK.Copy_MK;

      -- main calculations
      AddVectorsH(VA, MultScalarVectorH(d2, Z, H+1, 2*H),
                  MultScalarVectorH(a2, MultVectorMatrix(E2,
                    MultMatricesH(MO, MK2, H+1, 2*H), H+1, 2*H), H+1, 2*H), H+1, 2*H);

      -- signal T1 about calculations end
      BoxOutput.Signal_output;

      Put_Line("Task T2 finished");
   end T2;

   -----------------------------------------------------------------------------
   -- Body of task 3 --
   task body T3 is
      a3, d3 : Integer;
      E3 : Vector;
      MK3 : Matrix;
   begin
      Put_Line("Task T3 started");

      -- input of d, B, MK
      d := 1;
      FillVectorWithOnes(B);
      FillMatrixWithOnes(MK);
      Box_d.Write_d(d);
      Box_MK.Write_MK(MK);

      -- signal about input of d, B, MK
      BoxInput.Signal_input;

      -- wait for input of data
      BoxInput.Wait_input;

      -- a3 = Bh * Ch
      a3 := MultVectorsH (B, C, 2*H+1, 3*H);

      -- a = a + a3
      Box_a.Calculation_a(a3);

      -- signal about calculation of a
      Box_a.Signal_calc_a;

      -- wait for calculation a in other tasks
      Box_a.Wait_a;

      -- copy a, d, E and MK
      a3 := Box_a.Copy_a;
      d3 := Box_d.Copy_d;
      E3 := Box_E.Copy_E;
      MK3 := Box_MK.Copy_MK;

      -- main calculations
      AddVectorsH(VA, MultScalarVectorH(d3, Z, 2*H+1, 3*H),
                  MultScalarVectorH(a3, MultVectorMatrix(E3,
                    MultMatricesH(MO, MK3, 2*H+1, 3*H), 2*H+1, 3*H), 2*H+1, 3*H), 2*H+1, 3*H);

      -- signal T1 about calculations end
      BoxOutput.Signal_output;

      Put_Line("Task T3 finished");
   end T3;

   -----------------------------------------------------------------------------
   -- Body of task 4 --
   task body T4 is
      a4, d4 : Integer;
      E4 : Vector;
      MK4 : Matrix;
   begin
      Put_Line("Task T4 started");

      -- input of C, E
      FillVectorWithOnes(C);
      FillVectorWithOnes(E);
      Box_E.Write_E(E);

      -- signal about input of C, E
      BoxInput.Signal_input;

      -- wait for input of data
      BoxInput.Wait_input;

      -- a4 = Bh * Ch
      a4 := MultVectorsH (B, C, 3*H+1, N);

      -- a = a + a4
      Box_a.Calculation_a(a4);

      -- signal about calculation of a
      Box_a.Signal_calc_a;

      -- wait for calculation a in other tasks
      Box_a.Wait_a;

      -- copy a, d, E and MK
      a4 := Box_a.Copy_a;
      d4 := Box_d.Copy_d;
      E4 := Box_E.Copy_E;
      MK4 := Box_MK.Copy_MK;

      -- main calculations
      AddVectorsH(VA, MultScalarVectorH(d4, Z, 3*H+1, N),
                  MultScalarVectorH(a4, MultVectorMatrix(E4,
                    MultMatricesH(MO, MK4, 3*H+1, N), 3*H+1, N), 3*H+1, N), 3*H+1, N);

      -- signal T1 about calculations end
      BoxOutput.Signal_output;

      Put_Line("Task T4 finished");
   end T4;
   begin
      null;
   end Task_Launch;

   -- Body of main programme
begin
   Put_Line("Lab05 started");
   Task_Launch;
   Put_Line("Lab05 finished");
end Lab05;
