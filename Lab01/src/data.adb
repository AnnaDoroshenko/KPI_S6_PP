with Text_IO, Ada.Integer_Text_IO;
use Text_IO, Ada.Integer_Text_IO;

-- Package Data, body --
package body Data is

   procedure FillVectorWithOnes (A : out Vector) is
   begin
      for i in 1..N loop
         A(i) := 1;
      end loop;      
   end FillVectorWithOnes;
   
   procedure FillMatrixWithOnes (MA : out Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
            MA(i,j) := 1;
         end loop;
      end loop;
   end FillMatrixWithOnes;
   
   -- Functions for the calculation --
   
   function SearchMinElemOfVectH (A : in Vector; st, fin: in Integer) return Integer is
      minElem : Integer := A(st);
   begin
      for i in st+1..fin loop
         if A(i) < minElem then
            minElem := A(i);
         end if;
      end loop;
      return minElem;  
   end SearchMinElemOfVectH;
   
   function SearchMin (a, b : in Integer) return Integer is
      min : Integer := a;
   begin
      if b < a then
         min := b;
      end if;
      return min;
   end SearchMin;
   
   function MultMatricesH (MA, MB : in Matrix; st, fin: in Integer) return Matrix is
      mRes : Matrix;
   begin
      for i in 1..N loop
         for j in st..fin loop
            mRes(i, j) := 0;
            for k in 1..N loop
               mRes(i, j) := mRes(i, j) + MA (i, k) * MB (k, j);
            end loop;
         end loop;
      end loop;
      return mRes;
   end MultMatricesH;
   
   function MultScalarMatrixH (scalar : in Integer; MA : Matrix; st, fin: in Integer) return Matrix is
      resMatrix : Matrix;
   begin 
      for i in 1..N loop
         for j in st..fin loop
            resMatrix(i, j) := scalar * MA(i,j);
         end loop;
      end loop;
      return resMatrix;
   end MultScalarMatrixH;
   
   procedure AddMatricesH (MR : out Matrix; MA, MB : in Matrix; st, fin: in Integer) is
   begin
      for i in 1..N loop
         for j in st..fin loop
            MR(i, j) := MA(i, j) + MB(i, j);
         end loop;
      end loop;
   end AddMatricesH;
   
   function CopyMatrix (MA : in Matrix) return Matrix is
      resMatrix : Matrix;
   begin
      for i in 1..N loop
         for j in 1..N loop
            resMatrix(i, j) := MA(i, j);
         end loop;
      end loop;
      return resMatrix;
   end CopyMatrix;
   
   -- Procedures for input/output of scalar, vector and matrix --
   
   procedure InputScalar (a : out Integer) is
   begin
      Get(a);
   end InputScalar;
   
   procedure InputVector (A : out Vector) is
   begin
      for i in 1..N loop
          Get(A(i));     
      end loop;
   end InputVector;
   
   procedure InputMatrix (MA : out Matrix) is
   begin
      for i in 1..N loop
          New_Line;
          for j in 1..N loop
              Get(MA(i, j));
          end loop;
      end loop;
   end InputMatrix; 
   
   procedure OutputScalar (a : in Integer) is
   begin
      Put(a);
   end OutputScalar;
   
   procedure OutputVector (A : in Vector) is
   begin
      for i in 1..N loop
          Put(A(i));
      end loop;
   end OutputVector;
                                               
   procedure OutputMatrix (MA : in Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
              Put(MA(i, j));
         end loop;
         New_Line;
      end loop;
   end OutputMatrix;
   
end Data;
