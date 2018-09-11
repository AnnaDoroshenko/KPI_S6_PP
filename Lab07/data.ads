generic
   N : Integer;
   H : Integer;
   
package Data is
	type Vector is array(Integer range<>) of Integer;
    subtype VectorH is Vector(1..H);
    subtype Vector2H is Vector(1..2*H);
    subtype Vector3H is Vector(1..3*H);
    subtype VectorN is Vector(1..N);

    type Matrix is array(Integer range<>) of VectorN;
    subtype MatrixH is Matrix(1..H);
    subtype Matrix2H is Matrix(1..2*H);
    subtype Matrix3H is Matrix(1..3*H);
    subtype MatrixN is Matrix(1..N);

	procedure VectorFillWithOnes (A : out Vector);
	procedure MatrixFillWithOnes (MA : out Matrix);
	function SearchMinElemOfVector(A : in Vector) return Integer;
	function SearchTotalMin (a, b : in Integer) return Integer;
	function MultMatrices (MA, MB : in Matrix) return Matrix;
	function MultScalarMatrix (scalar : in Integer; MA : Matrix) return Matrix;
	procedure AddMatrices (MR : out Matrix; MA, MB : in Matrix);
	procedure OutputMatrix (MA : in Matrix);

end Data;