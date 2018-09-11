/**
* Programming for Parallel Computer Systems
* Lab 4. OpenMP. Barriers, Critical Sections
*
* MA = (B * C) * (MT * MK) + e * MO
*
* Author: Anna Doroshenko
* Group: IO-52
* Date: 04.04.2018
*/

#include <iostream>	
#include <windows.h>
#include <algorithm>
#include <omp.h>

static const unsigned int N = 2000;			// vector/matrix size 
static const unsigned int P = 6;			// amount of the processors
static const unsigned int H = N / P;		// subvector/submatrix size 


struct Vector {
private:
	int vector[N];

public:
	Vector() {
		std::fill(vector, vector + N, 0);
	}

	int& operator[](unsigned int i)
	{
		return vector[i];
	}

	const int& operator[](unsigned int i) const
	{
		return vector[i];
	}
};

struct Matrix {
private:
	Vector matrix[N];

public:
	Vector& operator[](unsigned int i)
	{
		return matrix[i];
	}

	const Vector& operator[](unsigned int i) const
	{
		return matrix[i];
	}
};

void TaskI(unsigned int tid);
void fillVectorWithOnes(struct Vector& vector);
void fillMatrixWithOnes(Matrix& matrix);
void setDefaultMatrix(Matrix& matrix);
void outputMatrix(const Matrix& matrix);
int multVectors(const struct Vector& vector1, const struct Vector& vector2, unsigned int st, unsigned int fin);
Matrix multMatrices(const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin);
Matrix multScalarMatrix(const unsigned int& scalar, Matrix& matrix, unsigned int st, unsigned int fin);
void addMatrices(Matrix& resMatrix, const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin);
Matrix copyMatrix(Matrix& matrix);

int a, e;
struct Vector B, C;
Matrix MA, MT, MK, MO;
//--------------------------------------------------------------------------
int main() {
	std::cout << "Lab04 started" << std::endl;

	omp_set_num_threads(P);
	a = 0;

	#pragma omp parallel
	{
		const unsigned int tid = omp_get_thread_num() + 1;
		TaskI(tid);
	}

	std::cout << "Lab04 finished" << std::endl;
	std::cin.get();
	std::cin.get();
}

//--------------------------------------------------------------------------
void TaskI(unsigned int tid)
{
	const unsigned int st = (tid - 1) * H;
	const unsigned int fin = tid * H;

	std::cout << "Thread " << tid << " started" << std::endl;

	//input of data
	switch (tid) {
	case 1:
		fillMatrixWithOnes(MK);
		e = 1;
		break;
	case 2:
		fillVectorWithOnes(C);
		fillMatrixWithOnes(MT);
		break;
	case 6:
		setDefaultMatrix(MA);
		fillVectorWithOnes(B);
		fillMatrixWithOnes(MO);
		break;
	default:
		break;
	}

	//input barrier1
	#pragma omp barrier

	int ai = multVectors(B, C, st, fin);

	#pragma omp critical(CS1)
	{
		a = a + ai;
	}

	//a barrier2
	#pragma omp barrier

	//copy a
	//critical section
	#pragma omp critical(copyA)
	{
		ai = a;
	}

	//copy e
	//critical section
	int ei = 0;
	#pragma omp critical(copyE)
	{
		ei = e;
	}

	//copy MK
	//critical section
	Matrix MKi;
	#pragma omp critical(copyMK)
	{
		MKi = copyMatrix(MK);
	}

	addMatrices(MA, multScalarMatrix(ai, multMatrices(MKi, MT, st, fin), st, fin), 
					multScalarMatrix(ei, MO, st, fin), st, fin);

	//output barrier3
	#pragma omp barrier

	//output MA
	if (N < 12)
	{
		switch (tid) {
		case 8:
			outputMatrix(MA);
			break;
		default:
			break;
		}	
	}
	
	std::cout << "Thread " << tid << " finished" << std::endl;
}

//--------------------------------------------------------------------------
void fillVectorWithOnes(struct Vector& vector)
{
	for (unsigned int i = 0; i < N; i++)
	{
		vector[i] = 1;
	}
}

void fillMatrixWithOnes(Matrix& matrix)
{
	for (unsigned int i = 0; i < N; i++)
	{
		for (unsigned int j = 0; j < N; j++)
		{
			matrix[i][j] = 1;
		}
	}
}

void setDefaultMatrix(Matrix& matrix) 
{
	for (unsigned int i = 0; i < N; i++) {
		for (unsigned int j = 0; j < N; j++) {
			matrix[i][j] = 0;
		}
	}
}

void outputMatrix(const Matrix& matrix) 
{
	#pragma omp parallel for
	for (int i = 0; i < N; i++) {
		const Vector& vec = matrix[i];
		for (unsigned int j = 0; j < N; j++) {
			std::cout << vec[j] << " ";
		}
		std::cout << std::endl;
	}
}

//--- Functions for the calculation ---
int multVectors(const struct Vector& vector1, const struct Vector& vector2, unsigned int st, unsigned int fin)
{
	int result = 0;
	#pragma omp parallel for
	for (int i = st; i < fin; i++) {
		result += vector1[i] * vector2[i];
	}

	return result;
}

Matrix multMatrices(const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin)
{
	Matrix resMatrix;
	#pragma omp parallel for
	for (int i = st; i < fin; i++)
	{
		for (unsigned int j = 0; j < N; j++)
		{
			unsigned int current = 0;
			for (unsigned int k = 0; k < N; k++)
			{
				current += matrix1[i][k] * matrix2[k][j];
			}
			resMatrix[i][j] = current;
		}
	}

	return resMatrix;
}

Matrix multScalarMatrix(const unsigned int& scalar, Matrix& matrix, unsigned int st, unsigned int fin)
{
	#pragma omp parallel for
	for (int i = st; i < fin; i++) {
		for (unsigned int j = 0; j < N; j++) {
			matrix[i][j] = scalar * matrix[i][j];
		}
	}

	return matrix;
}

void addMatrices(Matrix& resMatrix, const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin) 
{
	#pragma omp parallel for
	for (int i = st; i < fin; i++) {
		for (unsigned int j = 0; j < N; j++) {
			resMatrix[i][j] = matrix1[i][j] + matrix2[i][j];
		}
	}
}

Matrix copyMatrix(Matrix& matrix)
{
	Matrix matrixCopy;
	#pragma omp parallel for
	for (int i = 0; i < N; i++)
	{
		for (unsigned int j = 0; j < N; j++)
		{
			matrixCopy[i][j] = matrix[i][j];
		}
	}
	return matrixCopy;
}