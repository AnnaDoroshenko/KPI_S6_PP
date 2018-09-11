--------------------------------------------------------------------------------
-- Programming for Parallel Computer Systems --
-- Lab 7. Ada. Rendezvous --

-- MA = MB*MC + MZ*(min(E)) --

-- Author: Anna Doroshenko --
-- Group: IO-52 --
-- Date: 01.05.2018 --
--------------------------------------------------------------------------------
with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;

procedure Lab07 is
	
   Storage : Integer := 50000000;
   N : Integer := 6;             -- size of the vector and the matrix
   P : Integer := 6;             -- amount of the processors
   H : Integer := N/P;           -- size of the subvector and the submatrix

   package NewData is new Data(N, H);
   use NewData;

   procedure Task_Launch is 
   	
   task T1 is
        pragma Task_Name("Task 1");
        pragma Storage_Size(Storage);

        entry DataMB(MB: in MatrixN);
        entry DataMC(MC: in Matrix2H);
        entry Data_a(min: in Integer);
        
        entry SearchMin(a: out Integer);
        entry Res_MA(MA: out MAtrixH);
    end T1;
    -----------------------------------
    task T2 is
        pragma Task_Name("Task 2");
        pragma Storage_Size(Storage);

        entry DataMZ_E(MZ: in Matrix3H; E: in Vector3H);
        entry DataMB(MB: in MatrixN);
        entry DataMC(MC: in MatrixH);
        entry Data_a(min: in Integer);

        entry SearchMin(a: out Integer);
        entry Res_MA(MA: out Matrix2H);
    end T2;
    -----------------------------------
    task T3 is 
        pragma Task_Name("Task 3");
        pragma Storage_Size(Storage);

        entry DataMZ_E(MZ: in Matrix2H; E: in Vector2H);
        entry DataMC(MC: in MatrixH);
    end T3;
    -----------------------------------
    task T4 is
        pragma Task_Name("Task 4");
        pragma Storage_Size(Storage);

        entry DataMZ_E(MZ: in MatrixH; E: in VectorH);
        entry DataMB(MB: in MatrixN);
        entry DataMC(MC: in Matrix2H);
        entry Data_a(min: in Integer);

        entry SearchMin(a: out Integer);
        entry Res_MA(MA: out Matrix3H);
    end T4;
    -----------------------------------
    task T5 is
        pragma Task_Name("Task 5");
        pragma Storage_Size(Storage);

        entry DataMZ_E(MZ: in MatrixH; E: in VectorH);
        entry DataMB(MB: in MatrixN);
        entry Data_a(Min: in Integer);

        entry SearchMin(A: out Integer);
        entry Res_MA(MA: out Matrix2H);
    end T5;
    -----------------------------------
    task T6 is
        pragma Task_Name("Task 6");
        pragma Storage_Size(Storage);

        entry DataMZ_E(MZ: in Matrix2H; E: in Vector2H);
        entry DataMB(MB: in MatrixN);
        entry DataMC(MC: in Matrix3H);
        entry Data_a(Min: in Integer);

        entry SearchMin(A: out Integer);
        entry Res_MA(MA: out MatrixH);
    end T6;
    -------------------------------------------------------
    -- tasks --
    task body T1 is
        MA1: MatrixH;
        MC1: Matrix2H;
        MB1, MZ1: MatrixN;
        E1: VectorN;
        a1: Integer;

    begin
        Put_Line("Task 1 started");

        -- input MZ, E
        MatrixFillWithOnes(MZ1);
        VectorFillWithOnes(E1);

        -- send MZ, E in T2 & T6
        T2.DataMZ_E(MZ1(H+1..4*H), E1(H+1..4*H));
        T6.DataMZ_E(MZ1(4*H+1..6*H), E1(4*H+1..6*H));
		
        -- receive MB from T2
        accept DataMB(MB: in MatrixN) do
            MB1(1..N) := MB(1..N);
        end DataMB;

        -- receive MC from T6
        accept DataMC(MC: in Matrix2H) do
            MC1(1..2*H) := MC(1..2*H);
        end DataMC;
		
        -- send MC in T2
        T2.DataMC(MC1(H+1..2*H));

        -- calculation of min
        a1 := SearchMinElemOFVector(E1(1..H));

        -- send a1 in T2
        accept SearchMin(a: out Integer) do
            a := a1;
        end SearchMin;

        -- receive a from T2
        accept Data_a(min: in Integer) do
            a1:= min;
        end Data_a;

        -- main calculation
        AddMatrices(MA1(1..H), MultMatrices(MC1(1..H), MB1(1..N)), MultScalarMatrix(a1, MZ1(1..H)));

        -- send MA in T2
        accept Res_MA(MA: out MatrixH) do
            MA(1..H) := MA1(1..H);
        end Res_MA;

        Put_Line("Task 1 finished");
    end T1;
    -------------------------------------------------------
    task body T2 is
        MA2: Matrix2H;
        MC2, MA2Calc: MatrixH;
        MZ2: Matrix3H;
        MB2: MatrixN;
        E2: Vector3H;
        a, a2: Integer;

	begin 
		Put_Line("Task 2 started");

        -- receive MZ, E from T1
        accept DataMZ_E(MZ: in Matrix3H; E: in Vector3H) do
            MZ2(1..3*H) := MZ(1..3*H);
            E2(1..3*H) := E(1..3*H);
        end DataMZ_E;

        -- send MZ, E in T3
        T3.DataMZ_E(MZ2(H+1..3*H), E2(H+1..3*H));

        -- receive MB from T3
        accept DataMB(MB: in MatrixN) do
            MB2(1..N) := MB(1..N);
        end DataMB;

        -- send MB in T1
        T1.DataMB(MB2(1..N));

        -- receive MC from T1
        accept DataMC(MC: in MatrixH) do
            MC2(1..H) := MC(1..H);
        end DataMC;

        -- calculation of min
        a2 := SearchMinElemOfVector(E2(1..H));

        -- receive a1 from T1 and search min(a1,a2)
        T1.SearchMin(a);
        a2 := SearchTotalMin(a, a2);

        -- send a2 in T3
        accept SearchMin(a: out Integer) do
            a := a2;
        end SearchMin;

        -- receive a from T3
        accept Data_a(min: in Integer) do
            a2:= min;
        end Data_a;

        -- send a in T1
        T1.Data_a(a2);

        -- receive MA from T1
        T1.Res_MA(MA2(1..H));

        -- main calculation
        AddMatrices(MA2Calc(1..H), MultMatrices(MC2(1..H), MB2(1..N)), MultScalarMatrix(a2, MZ2(1..H)));
		MA2(H+1..2*H) := MA2Calc(1..H);

        -- send MA in T3
        accept Res_MA(MA: out Matrix2H) do
            MA(1..2*H) := MA2(1..2*H);
        end Res_MA;

        Put_Line("Task 2 finished");
    end T2;
    -------------------------------------------------------
    task body T3 is
        MA3, MB3: MatrixN;
        MC3, MA3calc: MatrixH;
        MZ3: Matrix2H;
		MA3calc1: Matrix3H;
        E3: Vector2H;
        a, a3: Integer;

    begin
        Put_Line("Task 3 started");

        -- input MB
        MatrixFillWithOnes(MB3);

  		-- receive MZ, E from T2
        accept DataMZ_E(MZ: in Matrix2H; E: in Vector2H) do
            MZ3(1..2*H) := MZ(1..2*H);
            E3(1..2*H) := E(1..2*H);
        end DataMZ_E;
        
        -- send MZ, E in T4
        T4.DataMZ_E(MZ3(H+1..2*H), E3(H+1..2*H));

        -- send MB in T4 & T2
        T4.DataMB(MB3(1..N));
        T2.DataMB(MB3(1..N));

        -- receive MC from T4
        accept DataMC(MC: in MatrixH) do
            MC3(1..H) := MC(1..H);
        end DataMC;

        -- calculation of min
        a3 := SearchMinElemOFVector(E3(1..H));

        -- receive a2 from T2 and search min(a2,a3)
        T2.SearchMin(a);
        a3 := SearchTotalMin(a, a3);

        -- receive a4 from T4 and search min(a4,a3)
        T4.SearchMin(a);
        a3 := SearchTotalMin(a, a3);

        -- send a in T4 & T2
        T4.Data_a(a3);
        T2.Data_a(a3);

        -- receive MA from T2
        T2.Res_MA(MA3(1..2*H));

		-- main calculation
		AddMatrices(MA3calc(1..H), MultMatrices(MC3(1..H), MB3(1..N)), MultScalarMatrix(a3, MZ3(1..H)));
		MA3(2*H+1..3*H) := MA3calc(1..H);

		-- receive MA from T4
        T4.Res_MA(MA3calc1(1..3*H));
        MA3(3*H+1..6*H) := MA3calc1(1..3*H);

        -- Output MA
		if (N < 13) then 
			OutputMatrix(MA3);
		end if;
	   	
        Put_Line("Task 3 finished");
    end T3;
    -------------------------------------------------------
    task body T4 is
        MA4: Matrix3H;
        MC4: Matrix2H;
        MZ4, MC4Calc: MatrixH;
        MB4: MatrixN;
        E4: VectorH;
        a, a4: Integer;

	begin
		Put_Line("Task 4 started");

        -- receive MZ, E from T3
        accept DataMZ_E(MZ: in MatrixH; E: in VectorH) do
            MZ4(1..H) := MZ(1..H);
            E4(1..H) := E(1..H);
        end DataMZ_E;

        -- receive MB from T3
        accept DataMB(MB: in MatrixN) do
            MB4(1..N) := MB(1..N);
        end DataMB;
	
        -- send MB in T5
        T5.DataMB(MB4(1..N));

        -- receive MC from T5
        accept DataMC(MC: in Matrix2H) do
            MC4(1..2*H) := MC(1..2*H);
        end DataMC;

        -- send MC in T3
        T3.DataMC(MC4(1..H));

        -- calculation of min
        a4 := SearchMinElemOfVector(E4(1..H));

        -- receive a5 from T5 and search min(a4,a5)
        T5.SearchMin(a);
        a4 := SearchTotalMin(a, a4);

        -- send a4 in T3
        accept SearchMin(a: out Integer) do
            a := a4;
        end SearchMin;

        -- receive a from T3
        accept Data_a(min: in Integer) do
            a4:= min;
        end Data_a;

        -- send a in T5
        T5.Data_a(a4);

		MC4calc(1..H) := MC4(H+1..2*H);
        -- main calculation
        AddMatrices(MA4(1..H), MultMatrices(MC4calc(1..H), MB4(1..N)), MultScalarMatrix(a4, MZ4(1..H)));

        -- receive MA from T5
        T5.Res_MA(MA4(H+1..3*H));

        -- send MA in T3
        accept Res_MA(MA: out Matrix3H) do
            MA(1..3*H) := MA4(1..3*H);
        end Res_MA;

        Put_Line("Task 4 finished");
    end T4;
    -------------------------------------------------------
    task body T5 is
        MA5: Matrix2H;
        MB5, MC5: MatrixN;
		MCintoT6 : Matrix3H;
        MZ5, MC5calc: MatrixH;
        E5: VectorH;
        a, a5: Integer;

    begin
        Put_Line("Task 5 started");

        -- input MC
        MatrixFillWithOnes(MC5);

		-- merge pieces of MC to send them in T6, T1 & T2
        MCintoT6(1..2*H) := MC5(1..2*H);
        MCintoT6(2*H+1..3*H) := MC5(5*H+1..6*H);
	
		-- receive MZ, E from T6
        accept DataMZ_E(MZ: in MatrixH; E: in VectorH) do
            MZ5(1..H) := MZ(1..H);
            E5(1..H) := E(1..H);
        end DataMZ_E;

		-- receive MB from T4
        accept DataMB(MB: in MatrixN) do
            MB5(1..N) := MB(1..N);
        end DataMB;

        -- send MB in T6
        T6.DataMB(MB5(1..N));

        -- send MC in T6 & T4
        T6.DataMC(MCintoT6(1..3*H));
        T4.DataMC(MC5(2*H+1..4*H));
    
        -- calculation of min
        a5 := SearchMinElemOFVector(E5(1..H));

        -- receive a6 from T6 and search min(a6, a5)
        T6.SearchMin(a);
        a5 := SearchTotalMin(a, a5);

        -- send a5 in T4
        accept SearchMin(a: out Integer) do 
            a := a5;
        end SearchMin;

        -- receive a from T4
        accept Data_a(min: in Integer) do
            a5 := min;
        end Data_a;
        
        -- send a in T6
        T6.Data_a(a5);

		MC5calc(1..H) := MC5(4*H+1..5*H);
        -- main calculation
        AddMatrices(MA5(1..H), MultMatrices(MC5(1..H), MB5(1..N)), MultScalarMatrix(a5, MZ5(1..H)));

        -- receive MA from T6
        T6.Res_MA(MA5(H+1..2*H));

        -- send MA in T4
        accept Res_MA(MA: out Matrix2H) do
            MA(1..2*H) := MA5(1..2*H);
        end Res_MA;

        Put_Line("Task 5 finished");
    end T5;
    -------------------------------------------------------
    task body T6 is
        MA6, MC6calc, MZ6calc: MatrixH;
        MC6: Matrix3H;
        MZ6: Matrix2H;
        MB6: MatrixN;
        E6: Vector2H;
		E6calc: VectorH;
        a6: Integer;

	begin
		Put_Line("Task 6 started");

		-- recieve MZ, E from T1
        accept DataMZ_E(MZ: in Matrix2H; E: in Vector2H) do
            MZ6(1..2*H) := MZ(1..2*H);
            E6(1..2*H) := E(1..2*H);
        end DataMZ_E;

        -- send MZ, E in T5
        T5.DataMZ_E(MZ6(1..H), E6(1..H));

		-- receive MB from T5
        accept DataMB(MB: in MatrixN) do
            MB6(1..N) := MB(1..N);
        end DataMB;

		-- recieve MC from T5
        accept DataMC(MC: in Matrix3H) do
            MC6(1..3*H) := MC(1..3*H);
        end DataMC;

        -- send MC in T1
        T1.DataMC(MC6(1..2*H));

        -- calculation of min
		E6calc(1..H) := E6(H+1..2*H);
        a6 := SearchMinElemOfVector(E6calc(1..H));

        -- send a6 in T5
        accept SearchMin(a: out Integer) do
            a := a6;
        end SearchMin;

        -- receive a from T5
        accept Data_a(min: in Integer) do
            a6:= min;
        end Data_a;

		MC6calc(1..H) := MC6(2*H+1..3*H);
		MZ6calc(1..H) := MZ6(H+1..2*H);
        -- main calculation
        AddMatrices(MA6(1..H), MultMatrices(MC6calc(1..H), MB6(1..N)), MultScalarMatrix(a6, MZ6calc(1..H)));

        -- send MA in T5
        accept Res_MA(MA: out MatrixH) do
            MA(1..H) := MA6(1..H);
        end Res_MA;

        Put_Line("Task 6 finished");
    end T6;
    -------------------------------------------------------
	begin	
		null;
	end Task_Launch;

-- Body of main programme
begin
   Put_Line("Lab07 started");
   Task_Launch;
   Put_Line("Lab07 finished");
end Lab07;


