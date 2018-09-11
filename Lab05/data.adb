with Text_IO, Ada.Integer_Text_IO;
use text_IO, Ada.Integer_Text_IO;

----- Body of package Data -----

package body data is
   
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
   
   function MultScalarVectorH (scalar : in Integer; VA : Vector; st, fin: in Integer) return Vector is
      resVector : Vector;
   begin 
      for i in st..fin loop
         resVector(i) := scalar * VA(i);
      end loop;
      return resVector;
   end MultScalarVectorH;
   
   function MultVectorsH (VA, VB : in Vector; st, fin: in Integer) return Integer is
      result : Integer := 0;
   begin
      for i in st..fin loop
         result := result + VA(i) * VB(i);
      end loop;
      return result;
   end MultVectorsH;
   
   function MultMatricesH (MA, MB : in Matrix; st, fin: in Integer) return Matrix is
      mRes : Matrix;
   begin
      for i in st..fin loop
         for j in 1..N loop
            mRes(i, j) := 0;
            for k in 1..N loop
               mRes(i, j) := mRes(i, j) + MA (i, k) * MB (k, j);
            end loop;
         end loop;
      end loop;
      return mRes;
   end MultMatricesH;
   
   function MultVectorMatrix (VA : in Vector; MA : in Matrix; st, fin: in Integer) return Vector is
      resVector : Vector;
   begin
      for i in st..fin loop
         resVector(i) := 0;
         for j in 1..N loop
            resVector(i) := resVector(i) + VA(j) * MA(i, j); 
         end loop;
      end loop;
      return resVector;
   end MultVectorMatrix;
   
   procedure AddVectorsH (VRes : out Vector; VA, VB : in Vector; st, fin: in Integer) is
   begin
      for i in st..fin loop
         VRes(i) := VA(i) + VB(i);
      end loop;
   end AddVectorsH;
   
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
   
   function CopyVector (VA : in Vector) return Vector is
      resVector : Vector;
   begin
      for i in 1..N loop
         resVector(i) := VA(i);
      end loop;
      return resVector;
   end CopyVector;
   
   procedure OutputVector (A : in Vector) is
   begin
      for i in 1..N loop
          Put(A(i));
      end loop;
   end OutputVector;
   
end data;
