/**
* Programming for Parallel Computer Systems
* Lab 8. MPI. Message passing. Graph
*
* MA = MB*MC + max(Z)*MZ
*
* Author: Anna Doroshenko
* Group: IO-52
* Date: 12.05.2018
*/

#include <iostream>	
#include <windows.h>
#include <mpi.h>
#include <algorithm>

const unsigned int N = 12;			// vector/matrix size 
const unsigned int P = 12;			// amount of processors
const unsigned int H = N / P;		// subvector/submatrix size 
const static unsigned int STACK_SIZE = 100000000;
const static unsigned int FULL = P;
const static bool IS_VECTOR = true;
const static bool IS_MATRIX = !IS_VECTOR;

struct Vector {
public:
	int * vector;

	const unsigned int hs;
	const unsigned int size;

	Vector(unsigned int hs) : hs(hs), size(hs * H) {
		vector = new int[size];
		std::fill(vector, vector + size, 0);
	}

	int& operator[](unsigned int i)
	{
		return vector[i];
	}

	const int& operator[](unsigned int i) const
	{
		return vector[i];
	}

	void* getVoidPtr() {
		return (void*)(vector);
	}
};

struct Matrix {
public:
	int * matrix;

	const unsigned int hs;
	const unsigned int size;

	Matrix(unsigned int hs) : hs(hs), size(hs * H * N) {
		matrix = new int[size];
		std::fill(matrix, matrix + size, 0);
	}

	int& operator[](unsigned int i)
	{
		return matrix[i];
	}

	const int& operator[](unsigned int i) const
	{
		return matrix[i];
	}

	void* getVoidPtr() {
		return (void*)(matrix);
	}
};

void fillVectorWithOnes(struct Vector& vector);
void fillMatrixWithOnes(Matrix& matrix);
void outputMatrix(const Matrix& matrix);
unsigned int getSize(bool isVector, unsigned int sizeHs);
//-----------------------------------------------------------------------------
void TFunction(unsigned int tid, MPI_Comm myComm) {
	Matrix MA(tid == 0 ? FULL : 1);
	Matrix MB(tid == 0 ? FULL : 1);
	Matrix MC(FULL);
	Matrix MZ(tid == 0 ? FULL : 1);
	Vector Z(tid == 0 ? FULL : 1);
	int a;
	int* buff = new int[(tid == 0) ? (N*N + N*N + N) : (H*N + H*N + H)];

	// data input & buffer filling
	if (tid == 0) {
		fillMatrixWithOnes(MB);
		fillMatrixWithOnes(MC);
		fillMatrixWithOnes(MZ);
		fillVectorWithOnes(Z);

		int sh = 0;
		for (unsigned int i = 0; i < P; i++) {
			memcpy((void*)(buff + sh), (void*)(MB.matrix + i * H * N), H * N * sizeof(int));
			sh += H * N;
			memcpy((void*)(buff + sh), (void*)(MZ.matrix + i * H * N), H * N * sizeof(int));
			sh += H * N;
			memcpy((void*)(buff + sh), (void*)(Z.vector + i * H), H * sizeof(int));
			sh += H;
		}
	}

	// send data
	MPI_Bcast(MC.getVoidPtr(), getSize(IS_MATRIX, FULL), MPI_INT, 0, myComm);

	MPI_Scatter((void*)buff, 2*H*N + H, MPI_INT, (void*)buff, 2*H*N + H, MPI_INT, 0, myComm);

	// receive data
	memcpy(MB.getVoidPtr(), (void*)(buff), H * N * sizeof(int));
	memcpy(MZ.getVoidPtr(), (void*)(buff + H * N), H * N * sizeof(int));
	memcpy(Z.getVoidPtr(), (void*)(buff + 2 * H * N), H * sizeof(int));

	// search local max
	a = Z[0];
	for (unsigned int i = 0; i < H; i++) {
		if (Z[i] > a) {
			a = Z[i];
		}
	}

	// gather max values
	int arrMax[P];
	MPI_Gather(&a, 1, MPI_INT, arrMax, 1, MPI_INT, 0, myComm);

	// search total max
	if (tid == 0) {
		for (unsigned int i = 0; i < P; i++) {
			if (arrMax[i] > a) {
				a = arrMax[i];
			}
		}
	}

	// send a
	MPI_Bcast(&a, 1, MPI_INT, 0, myComm);

	// main calculations
	for (unsigned int k = 0; k < H; k++) {
		for (unsigned int i = 0; i < N; i++) {
			int mult = 0;
			for (unsigned int j = 0; j < N; j++) {
				mult += MB[k*N + j] * MC[j*N + i];
			}

			MA[k * N + i] = mult + a * MZ[k * N + i];
		}
	}

	// gather result
	MPI_Gather(MA.getVoidPtr(), getSize(IS_MATRIX, 1), MPI_INT,
		MA.getVoidPtr(), getSize(IS_MATRIX, 1), MPI_INT, 0, myComm);

	// output result
	if (tid == 0) {
		outputMatrix(MA);
	}
}
//--------------------------------------------------------------------------
int main() {
	int size, rank;
	MPI_Init(0, 0);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (rank == 0) {
		std::cout << "Lab08 started" << std::endl;
	}

	// create graph
	const int nodes = P;
	int nnodes[nodes] = { 4, 2, 1, 3, 1, 1, 2, 1, 4, 1, 1, 1 };
	int indices[nodes];
	int edges[] = {
		2, 4, 7, 9, 	//1
		1, 3,			//2
		2,				//3
		1, 5, 6,		//4
		4,				//5
		4,				//6
		1, 8,			//7
		7,				//8
		1, 10, 11, 12,	//9
		9, 				//10
		9,				//11
		9				//12
	};

	indices[0] = nnodes[0];
	for (unsigned int i = 1; i < nodes; i++) {
		indices[i] = indices[i - 1] + nnodes[i];
	}
	const unsigned int edgeSize = nnodes[nodes - 1];

	for (unsigned int i = 0; i < edgeSize; i++) edges[i]--;

	MPI_Comm myComm;
	MPI_Graph_create(MPI_COMM_WORLD, nodes, indices, edges, false, &myComm);

	TFunction(rank, myComm);

	MPI_Finalize();
	std::cout << "Lab08 finished" << std::endl;

	return 0;
}
//--------------------------------------------------------------------------
void fillVectorWithOnes(struct Vector& vector)
{
	for (unsigned int i = 0; i < vector.size; i++)
	{
		vector[i] = 1;
	}
}

void fillMatrixWithOnes(Matrix& matrix)
{
	for (unsigned int i = 0; i < matrix.size; i++)
	{
		matrix[i] = 1;
	}
}

void outputMatrix(const Matrix& matrix)
{
	for (unsigned int i = 0; i < matrix.hs * H; i++)
	{
		for (unsigned int j = 0; j < N; j++)
		{
			std::cout << matrix[i * N + j] << " ";
		}
		std::cout << std::endl;
	}
}

unsigned int getSize(bool isVector, unsigned int sizeHs) {
	return sizeHs * H * (isVector ? 1 : N);
}