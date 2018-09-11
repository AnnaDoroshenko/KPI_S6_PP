using System;

namespace Lab03
{
    class Data
    {
        private int N;

        public Data(int N)
        {
            this.N = N;
        }

        public void FillVectorWithOnes(ref int[] vector)
        {
            for (int i = 0; i < N; i++)
            {
                vector[i] = 1;
            }
        }

        public void SetDefaultVector(ref int[] vector)
        {
            for (int i = 0; i < N; i++)
            {
                vector[i] = 0;
            }
        }

        public void FillMatrixWithOnes(ref int[,] matrix)
        {
            for (int i = 0; i < N; i++)
            {
                for (int j = 0; j < N; j++)
                {
                    matrix[i, j] = 1;
                }
            }
        }

        public void OutputVector(ref int[] vector)
        {
            for (int i = 0; i < N; i++)
            {
                Console.Write(vector[i] + " ");
            }
            Console.WriteLine("");
        }

        //--- Functions for the calculation ---
        public void SortVector(ref int[] vector, int st, int fin)
        {
            int i = st, j = fin - 1;
            int tmp;
            int mid = vector[(st + fin) / 2];

            while (i <= j)
            {
                while (vector[i] < mid)
                {
                    i++;
                }
                while (vector[j] > mid)
                {
                    j--;
                }

                if (i <= j)
                {
                    tmp = vector[i];
                    vector[i] = vector[j];
                    vector[j] = tmp;
                    i++;
                    j--;
                }
            };

            if (st < j)
            {
                SortVector(ref vector, st, j);
            }
            if (i < fin)
            {
                SortVector(ref vector, i, fin);
            }
        }

        public void SortMergeVector(ref int[] vector, int st, int fin)
        {
            int[] result = new int[N];
            int i = 0;

            int size = (fin + 1 - st) / 2;
            int v1 = st;
            int v2 = st + size;

            while (i < 2 * size)
            {
                if (v1 == st + size)
                { // first vector depleted
                    result[i] = vector[v2++];
                }
                else if (v2 == st + 2 * size)
                { // second vector depleted
                    result[i] = vector[v1++];
                }
                else
                {
                    result[i] = vector[v1] < vector[v2] ? vector[v1++] : vector[v2++];
                }
                i++;
            }

            // Replace with new vector
            for (i = 0; i < 2 * size; i++)
            {
                vector[st + i] = result[i];
            }
        }

        public int[] MultScalarVector(int scalar, ref int[] vector, int st, int fin)
        {
            for (int i = st; i < fin; i++)
            {
                vector[i] = scalar * vector[i];
            }

            return vector;
        }

        public int[,] MultMatrices(ref int[,] matrix1, ref int[,] matrix2, int st, int fin)
        {
            int[,] resMatrix = new int[N, N];
            for (int i = st; i < fin; i++)
            {
                for (int j = 0; j < N; j++)
                {
                    int current = 0;
                    for (int k = 0; k < N; k++)
                    {
                        current += matrix1[i, k] * matrix2[k, j];
                    }
                    resMatrix[i, j] = current;
                }
            }

            return resMatrix;
        }

        public int[] MultVectorMatrix(ref int[] vector, int[,] matrix, int st, int fin)
        {
            int[] resVector = new int[N];
            for (int i = st; i < fin; i++)
            {
                resVector[i] = 0;
                for (int j = 0; j < N; j++)
                {
                    resVector[i] = resVector[i] + vector[j] * matrix[i, j];
                }
            }

            return resVector;
        }

        public void AddVectors(ref int[] resVector, ref int[] vector1, ref int[] vector2, int st, int fin)
        {
            for (int i = st; i < fin; i++)
            {
                resVector[i] = vector1[i] + vector2[i];
            }
        }

        public int[] CopyVector(ref int[] vector)
        {
            int[] vecCopy = new int[N];
            for (int i = 0; i < N; i++)
            {
                vecCopy[i] = vector[i];
            }

            return vecCopy;
        }

        public int[,] CopyMatrix(ref int[,] matrix)
        {
            int[,] matrixCopy = new int[N, N];
            for (int i = 0; i < N; i++)
            {
                for (int j = 0; j < N; j++)
                {
                    matrixCopy[i, j] = matrix[i, j];
                }
            }

            return matrixCopy;
        }
    }
}