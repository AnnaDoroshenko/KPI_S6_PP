generic
   N : Integer;

package data is
   
   -- Declaration of types --
   type Vector is array(1..N) of Integer;
   type Matrix is array(1..N, 1..N) of Integer;
   
   procedure FillVectorWithOnes (A : out Vector);
   procedure FillMatrixWithOnes (MA : out Matrix);
   
   function MultScalarVectorH (scalar : in Integer; VA : Vector; st, fin: in Integer) return Vector;
   function MultVectorsH (VA, VB : in Vector; st, fin: in Integer) return Integer;
   function MultMatricesH (MA, MB : in Matrix; st, fin: in Integer) return Matrix;
   function MultVectorMatrix (VA : in Vector; MA : in Matrix; st, fin: in Integer) return Vector;
   procedure AddVectorsH (VRes : out Vector; VA, VB : in Vector; st, fin: in Integer);
   function CopyMatrix (MA : in Matrix) return Matrix;
   function CopyVector (VA : in Vector) return Vector;
   
   procedure OutputVector (A : in Vector);
   
end data;
