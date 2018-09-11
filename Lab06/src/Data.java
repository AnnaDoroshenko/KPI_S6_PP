//------------------------------------------------ Data ----------------------------------------------------------------
import java.util.Arrays;

public class Data {

    private static int N;

    public Data(int n) {
        N = n;
    }

    public void fillVectorWithOnes(int[] vector) {
        Arrays.fill(vector, 1);
    }

    public void fillMatrixWithOnes(int[][] matrix) {
        for (int[] elem : matrix) {
            Arrays.fill(elem, 1);
        }
    }

    public void outputVector(int[] vector) {
        for (int i = 0; i < N; i++) {
            System.out.print(vector[i] + " ");
        }
    }

    public void outputMatrix(int[][] matrix) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                System.out.print(matrix[i][j] + " ");
            }
            System.out.println();
        }
    }

    //--- Functions for the calculation ---
    public int[] multScalarVectorH (int scalar, int[] vector, int st, int fin){
        for (int i = st; i < fin; i++) {
            vector[i] = scalar * vector[i];
        }

        return vector;
    }

    public int multVectorsH(int[] vector1, int[] vector2, int st, int fin) {
        int result = 0;
        for (int i = st; i < fin; i++) {
            result += vector1[i] * vector2[i];
        }

        return result;
    }

    public int[][] multMatricesH(int[][] matrix1, int[][] matrix2, int st, int fin) {
        int[][] resMatrix = new int[N][N];
        for (int i = st; i < fin; i++) {
            for (int j = 0; j < N; j++) {
                resMatrix[i][j] = 0;
                for (int k = 0; k < N; k++) {
                    resMatrix[i][j] = resMatrix[i][j] + matrix1[i][k] * matrix2[k][j];
                }
            }
        }

        return resMatrix;
    }

    public int[] multVectorMatrix(int[] vector, int[][] matrix, int st, int fin) {
        int[] resVector = new int[N];
        for (int i = st; i < fin; i++) {
            resVector[i] = 0;
            for (int j = 0; j < N; j++) {
                resVector[i] = resVector[i] + vector[j] * matrix[i][j];
            }
        }

        return resVector;
    }

    public void addVectors(int[] resVector, int[] vector1, int[] vector2, int st, int fin) {
        for (int i = st; i < fin; i++) {
            resVector[i] = vector1[i] + vector2[i];
        }
    }

    public static int[][] copyMatrix(int[][] matrix) {
        int[][] matrixCopy = new int[N][N];
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                matrixCopy[i][j] = matrix[i][j];
            }
        }

        return matrixCopy;
    }

    public static int[] copyVector(int[] vector) {
        int[] vectorCopy = new int[N];
        for (int i = 0; i < N; i++) {
            vectorCopy[i] = vector[i];
        }

        return vectorCopy;
    }
}
