with Text_IO, Ada.Integer_Text_IO;
use Text_IO, Ada.Integer_Text_IO;

-- Package Data, body --
package body Data is

   procedure VectorFillWithOnes (A : out Vector) is
   begin
      for i in 1..N loop
         A(i) := 1;
      end loop; 
   end VectorFillWithOnes;
   
   procedure MatrixFillWithOnes (MA : out Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
            MA(i)(j) := 1;
         end loop;
      end loop;
   end MatrixFillWithOnes;

   -- Functions for the calculation --
   
   function SearchMinElemOfVector(A : in Vector) return Integer is
      minElem : Integer := A(1);
   begin
      for i in 1..h loop
         if A(i) < minElem then
            minElem := A(i);
         end if;
      end loop;
      return minElem;  
   end SearchMinElemOfVector;

   function SearchTotalMin (a, b : in Integer) return Integer is
      min : Integer := a;
   begin
      if b < a then
         min := b;
      end if;
      return min;
   end SearchTotalMin;

   function MultMatrices (MA, MB : in Matrix) return Matrix is
      mRes : MatrixN;
   begin
      for i in 1..H loop
         for j in 1..N loop
            mRes(i)(j) := 0;
            for k in 1..N loop
               mRes(i)(j) := mRes(i)(j) + MA (i)(k) * MB (k)(j);
            end loop;
         end loop;
      end loop;
      return mRes;
   end MultMatrices;

   function MultScalarMatrix (scalar : in Integer; MA : Matrix) return Matrix is
      resMatrix : MatrixN;
   begin 
      for i in 1..H loop
         for j in 1..N loop
            resMatrix(i)(j) := scalar * MA(i)(j);
         end loop;
      end loop;
      return resMatrix;
   end MultScalarMatrix;

   procedure AddMatrices (MR : out Matrix; MA, MB : in Matrix) is
   begin
      for i in 1..H loop
         for j in 1..N loop
            MR(i)(j) := MA(i)(j) + MB(i)(j);
         end loop;
      end loop;
   end AddMatrices;

   procedure OutputMatrix (MA : in Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
              Put(MA(i)(j));
         end loop;
         New_Line;
      end loop;
   end OutputMatrix;
   
end Data;

