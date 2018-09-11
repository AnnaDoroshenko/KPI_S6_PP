generic
   N : Integer;
   
package Data is

   -- Declaration of private types --
   type Vector is private;
   type Matrix is private;
   
   procedure InputScalar (a : out Integer);  
   procedure InputVector (A : out Vector);                 
   procedure InputMatrix (MA : out Matrix);
   procedure OutputScalar (a : in Integer);
   procedure OutputVector (A : in Vector);             
   procedure OutputMatrix (MA : in Matrix);
   
   procedure FillVectorWithOnes (A : out Vector);
   procedure FillMatrixWithOnes (MA : out Matrix);
   
   function SearchMinElemOfVectH (A : Vector; st, fin: in Integer) return Integer;
   function SearchMin (a, b : Integer) return Integer;
   function MultMatricesH (MA, MB : Matrix; st, fin: in Integer) return Matrix;
   function MultScalarMatrixH (scalar : Integer; MA : Matrix; st, fin: in Integer) return Matrix;
   procedure AddMatricesH (MR : out Matrix; MA, MB : Matrix; st, fin: in Integer);                      
   function CopyMatrix (MA : in Matrix) return Matrix;
   
   -- Definition of private types --
private
   type Vector is array(1..N) of Integer;
   type Matrix is array(1..N, 1..N) of Integer;
   
end Data;
