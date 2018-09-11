/**
* Programming for Parallel Computer Systems
* Lab 2. WinAPI. Semaphores, Events, Mutexes, Critical Sections
*
* A = sort(Z) * d + e * T * (MO * MK)
*
* Author: Anna Doroshenko
* Group: IO-52
* Date: 14.03.2018
*/

#include <iostream>	
#include <windows.h>
#include <algorithm>

const unsigned int N = 4;			// vector/matrix size 
const unsigned int P = 4;			// amount of the processors
const unsigned int H = N / P;		// subvector/submatrix size 


struct Vector {
private:
	unsigned int vector[N];

public:
	Vector() {
		std::fill(vector, vector + N, 0);
	}

	unsigned int& operator[](unsigned int i)
	{
		return vector[i];
	}

	const unsigned int& operator[](unsigned int i) const
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


void T1();
void T2();
void T3();
void T4();
void fillVectorWithOnes(struct Vector& vector);
void setDefaultVector(struct Vector& vector);
void fillMatrixWithOnes(struct Matrix& matrix);
void outputVector(const struct Vector& vector);
void sortVector(struct Vector& vector, unsigned int st, unsigned int fin);
void sortMergeVector(struct Vector& vector, unsigned int st, unsigned int fin);
Vector multScalarVector(const unsigned int& scalar, struct Vector& vector, unsigned int st, unsigned int fin);
Matrix multMatrices(const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin);
Vector multVectorMatrix(const struct Vector& vector, const Matrix& matrix, unsigned int st, unsigned int fin);
void addVectors(struct Vector& resVector, const struct Vector& vector1, const struct Vector& vector2, unsigned int st, unsigned int fin);
Vector copyVector(struct Vector& vector);
Matrix copyMatrix(Matrix& matrix);

void outputMatrix(const Matrix& matrix) {
	for (unsigned int i = 0; i < N; i++) {
		const Vector& vec = matrix[i];
		for (unsigned int j = 0; j < N; j++) {
			std::cout << vec[j] << " ";
		}
		std::cout << std::endl;
	}
}

unsigned int d, e;
struct Vector T, A, Z;
Matrix MK, MO;

//--- Semaphores ---
HANDLE S1;
HANDLE S2;
HANDLE S3;

//--- Mutexes ---
HANDLE M1;
HANDLE M2;

//--- Critical Sections ---
CRITICAL_SECTION CS1;

//--- Events ---
HANDLE E0;
HANDLE E1;
HANDLE E2;
HANDLE E3;
HANDLE E4;
HANDLE E5;
HANDLE E6;

//--------------------------------------------------------------------------
int main() {
	std::cout << "Lab02 started" << std::endl;

	DWORD Tid1, Tid2, Tid3, Tid4;
	HANDLE hThread1, hThread2, hThread3, hThread4;

	setDefaultVector(A);

	//--- Semaphores ---
	// default security attributes
	// initial count
	// maximum count
	// unnamed semaphore
	S1 = CreateSemaphore(NULL, 0, 3, NULL);
	S2 = CreateSemaphore(NULL, 0, 3, NULL);
	S3 = CreateSemaphore(NULL, 0, 3, NULL);

	//--- Mutexes ---
	// default security attributes
	// initially not owned
	// unnamed
	M1 = CreateMutex(NULL, FALSE, NULL);
	M2 = CreateMutex(NULL, FALSE, NULL);

	//--- Critical Sections ---
	InitializeCriticalSection(&CS1);

	//--- Events ---
	// default security attibutes
	// TRUE => manual-reset event, FALSE => automatic
	// FALSE => initial - non-signaled, TRUE => signaled
	// unnamed event
	E0 = CreateEvent(NULL, TRUE, FALSE, NULL);
	E1 = CreateEvent(NULL, FALSE, FALSE, NULL);
	E2 = CreateEvent(NULL, FALSE, FALSE, NULL);
	E3 = CreateEvent(NULL, FALSE, FALSE, NULL);
	E4 = CreateEvent(NULL, FALSE, FALSE, NULL);
	E5 = CreateEvent(NULL, FALSE, FALSE, NULL);
	E6 = CreateEvent(NULL, FALSE, FALSE, NULL);

	// 1st arg - security attributes
	// 2nd arg - stack size
	// 3rd arg - start address (thread function)
	// 4th arg - parameter
	// 5th arg - creation flags
	// 6th arg - thread id
	hThread1 = CreateThread(NULL, 30000000, (LPTHREAD_START_ROUTINE)T1, NULL, 0, &Tid1);
	hThread2 = CreateThread(NULL, 30000000, (LPTHREAD_START_ROUTINE)T2, NULL, 0, &Tid2);
	hThread3 = CreateThread(NULL, 30000000, (LPTHREAD_START_ROUTINE)T3, NULL, CREATE_SUSPENDED, &Tid3);
	hThread4 = CreateThread(NULL, 30000000, (LPTHREAD_START_ROUTINE)T4, NULL, 0, &Tid4);

	SetThreadPriority(hThread1, THREAD_PRIORITY_NORMAL);
	SetThreadPriority(hThread2, THREAD_PRIORITY_LOWEST);
	SetThreadPriority(hThread3, THREAD_PRIORITY_HIGHEST);
	SetThreadPriority(hThread4, THREAD_PRIORITY_NORMAL);

	ResumeThread(hThread3);

	WaitForSingleObject(hThread1, INFINITE);
	WaitForSingleObject(hThread2, INFINITE);
	WaitForSingleObject(hThread3, INFINITE);
	WaitForSingleObject(hThread4, INFINITE);

	CloseHandle(hThread1);
	CloseHandle(hThread2);
	CloseHandle(hThread3);
	CloseHandle(hThread4);

	DeleteCriticalSection(&CS1);

	std::cout << "Lab02 finished" << std::endl;
	std::cin.get();
	std::cin.get();
}

//--------------------------------------------------------------------------
//--- Threads ---
void T1() {
	const unsigned int st = 0;
	const unsigned int fin = H;

	std::cout << "Thread 1 started" << std::endl;

	//input of d, e and MK
	d = 1;
	e = 1;
	fillMatrixWithOnes(MK);

	//signal T2, T3, T4 about input of d, e and MK
	ReleaseSemaphore(S1, 3, NULL);

	//wait for input of data in T2, T4
	WaitForSingleObject(S2, INFINITE);
	WaitForSingleObject(S3, INFINITE);

	//sort Zh
	sortVector(Z, st, fin);

	//wait for sort Zh part in T2 
	WaitForSingleObject(E1, INFINITE);

	//merge sort S1=sort*(Zh;Zh)
	sortMergeVector(Z, 0, 2 * H);

	//copy T
	WaitForSingleObject(M1, INFINITE);
	const struct Vector T1 = copyVector(T);
	ReleaseMutex(M1);

	//copy d, e
	//critical section
	EnterCriticalSection(&CS1);
	unsigned int d1 = d;
	unsigned int e1 = e;
	LeaveCriticalSection(&CS1);

	//copy MO
	WaitForSingleObject(M2, INFINITE);
	const Matrix MO1 = copyMatrix(MO);
	ReleaseMutex(M2);

	//wait for merge sort S2=sort*(Zh;Zh) in T3
	WaitForSingleObject(E2, INFINITE);

	//merge sort S=sort*(S1;S2)
	sortMergeVector(Z, 0, N);

	//signal T2, T3, T4 about end of total merge sort
	SetEvent(E0);

	//main calculations
	addVectors(A, multScalarVector(d1, Z, st, fin),
		multScalarVector(e1,
			multVectorMatrix(T1, multMatrices(MO1, MK, st, fin), st, fin), st, fin), st, fin);

	//signal T4 about end of calculation
	SetEvent(E4);

	std::cout << "Thread 1 finished" << std::endl;
}
//--------------------------------------------------------------------------
void T2() {
	const unsigned int st = H;
	const unsigned int fin = 2 * H;

	std::cout << "Thread 2 started" << std::endl;

	//input of T and MO
	fillVectorWithOnes(T);
	fillMatrixWithOnes(MO);

	//signal T1, T3, T4 about input of T and MO
	ReleaseSemaphore(S2, 3, NULL);

	//wait for input of data in T1, T4
	WaitForSingleObject(S1, INFINITE);
	WaitForSingleObject(S3, INFINITE);

	//sort Zh
	sortVector(Z, st, fin);

	//signal T1 about end of sort Zh part 
	SetEvent(E1);

	//copy MO
	WaitForSingleObject(M2, INFINITE);
	const Matrix MO2 = copyMatrix(MO);
	ReleaseMutex(M2);

	//copy d, e
	//critical section
	EnterCriticalSection(&CS1);
	unsigned int d2 = d;
	unsigned int e2 = e;
	LeaveCriticalSection(&CS1);

	//copy T
	WaitForSingleObject(M1, INFINITE);
	const struct Vector T2 = copyVector(T);
	ReleaseMutex(M1);

	//wait for end of total merge sort in T1
	WaitForSingleObject(E0, INFINITE);

	//main calculations
	addVectors(A, multScalarVector(d2, Z, st, fin),
		multScalarVector(e2,
			multVectorMatrix(T2, multMatrices(MO2, MK, st, fin), st, fin), st, fin), st, fin);

	//signal T4 about end of calculation
	SetEvent(E5);

	std::cout << "Thread 2 finished" << std::endl;
}
//--------------------------------------------------------------------------
void T3() {
	const unsigned int st = 2 * H;
	const unsigned int fin = 3 * H;

	std::cout << "Thread 3 started" << std::endl;

	//wait for input of data in T1, T2 and T4
	WaitForSingleObject(S1, INFINITE);
	WaitForSingleObject(S2, INFINITE);
	WaitForSingleObject(S3, INFINITE);

	//sort Zh
	sortVector(Z, st, fin);

	//copy T
	WaitForSingleObject(M1, INFINITE);
	const struct Vector T3 = copyVector(T);
	ReleaseMutex(M1);

	//copy d, e
	//critical section
	EnterCriticalSection(&CS1);
	unsigned int d3 = d;
	unsigned int e3 = e;
	LeaveCriticalSection(&CS1);

	//copy MO
	WaitForSingleObject(M2, INFINITE);
	const Matrix MO3 = copyMatrix(MO);
	ReleaseMutex(M2);

	//wait for sort Zh part in T4 
	WaitForSingleObject(E3, INFINITE);

	//merge sort S2=sort*(Zh;Zh)
	sortMergeVector(Z, 2 * H, N);

	//signal T1 about end of merge sort S2=sort*(Zh;Zh)
	SetEvent(E2);

	//wait for end of total merge sort in T1
	WaitForSingleObject(E0, INFINITE);

	//main calculations
	addVectors(A, multScalarVector(d3, Z, st, fin),
		multScalarVector(e3,
			multVectorMatrix(T3, multMatrices(MO3, MK, st, fin), st, fin), st, fin), st, fin);

	//signal T4 about end of calculation
	SetEvent(E6);

	std::cout << "Thread 3 finished" << std::endl;
}
//--------------------------------------------------------------------------
void T4() {
	const unsigned int st = 3 * H;
	const unsigned int fin = N;

	std::cout << "Thread 4 started" << std::endl;

	//input of Z
	fillVectorWithOnes(Z);

	//signal T2, T3, T4 about input of Z
	ReleaseSemaphore(S3, 3, NULL);

	//wait for input of data in T1, T2
	WaitForSingleObject(S1, INFINITE);
	WaitForSingleObject(S2, INFINITE);

	//sort Zh
	sortVector(Z, st, fin);

	//signal T3 about end of sort Zh part 
	SetEvent(E3);

	//copy MO
	WaitForSingleObject(M2, INFINITE);
	const Matrix MO4 = copyMatrix(MO);
	ReleaseMutex(M2);

	//copy d, e
	//critical section
	EnterCriticalSection(&CS1);
	unsigned int d4 = d;
	unsigned int e4 = e;
	LeaveCriticalSection(&CS1);

	//copy T
	WaitForSingleObject(M1, INFINITE);
	const struct Vector T4 = copyVector(T);
	ReleaseMutex(M1);

	//wait for end of total merge sort in T1
	WaitForSingleObject(E0, INFINITE);

	//main calculations
	addVectors(A, multScalarVector(d4, Z, st, fin),
		multScalarVector(e4,
			multVectorMatrix(T4, multMatrices(MO4, MK, st, fin), st, fin), st, fin), st, fin);

	//wait for calculations end in T1, T2 and T3 
	WaitForSingleObject(E4, INFINITE);
	WaitForSingleObject(E5, INFINITE);
	WaitForSingleObject(E6, INFINITE);

	//Output A
	outputVector(A);

	std::cout << "Thread 4 finished" << std::endl;
}

//--------------------------------------------------------------------------
void fillVectorWithOnes(struct Vector& vector)
{
	for (unsigned int i = 0; i < N; i++)
	{
		vector[i] = 1;
	}
}

void setDefaultVector(struct Vector& vector)
{
	for (unsigned int i = 0; i < N; i++)
	{
		vector[i] = 0;
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

void outputVector(const struct Vector& vector)
{
	for (unsigned int i = 0; i < N; i++)
	{
		std::cout << vector[i] << " ";
	}
}

//--- Functions for the calculation ---
void sortVector(struct Vector& vector, unsigned int st, unsigned int fin)
{
	int i = st, j = fin;
	int tmp;
	int mid = vector[(st + fin) / 2];

	while (i <= j) {
		while (vector[i] < mid) {
			i++;
		}
		while (vector[j] > mid) {
			j--;
		}

		if (i <= j) {
			tmp = vector[i];
			vector[i] = vector[j];
			vector[j] = tmp;
			i++;
			j--;
		}
	};

	if (st < j) {
		sortVector(vector, st, j);
	}
	if (i < fin) {
		sortVector(vector, i, fin);
	}
}

void sortMergeVector(struct Vector& vector, unsigned int st, unsigned int fin) 
{
	struct Vector result;
	unsigned int i = 0;

	const unsigned int size = (fin + 1 - st) / 2;
	unsigned int v1 = st;
	unsigned int v2 = st + size;

	while (i < 2 * size) {
		if (v1 == st + size) { // first vector depleted
			result[i] = vector[v2++];
		}
		else if (v2 == st + 2 * size) { // second vector depleted
			result[i] = vector[v1++];
		}
		else {
			result[i] = vector[v1] < vector[v2] ? vector[v1++] : vector[v2++];
		}
		i++;
	}

	// Replace with new vector
	for (i = 0; i < 2 * size; i++) {
		vector[st + i] = result[i];
	}
}

struct Vector multScalarVector(const unsigned int& scalar, struct Vector& vector, unsigned int st, unsigned int fin)
{
	for (unsigned int i = st; i < fin; i++)
	{
		vector[i] = scalar * vector[i];
	}

	return vector;
}

Matrix multMatrices(const Matrix& matrix1, const Matrix& matrix2, unsigned int st, unsigned int fin)
{
	Matrix resMatrix;
	for (unsigned int i = st; i < fin; i++)
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

struct Vector multVectorMatrix(const struct Vector& vector, const Matrix& matrix, unsigned int st, unsigned int fin)
{
	struct Vector resVector;
	for (unsigned int i = st; i < fin; i++)
	{
		resVector[i] = 0;
		for (unsigned int j = 0; j < N; j++)
		{
			resVector[i] = resVector[i] + vector[j] * matrix[i][j];
		}
	}
	return resVector;
}

void addVectors(struct Vector& resVector, const struct Vector& vector1, const struct Vector& vector2, unsigned int st, unsigned int fin)
{
	for (unsigned int i = st; i < fin; i++)
	{
		resVector[i] = vector1[i] + vector2[i];
	}
}

struct Vector copyVector(struct Vector& vector)
{
	struct Vector vecCopy;
	for (unsigned int i = 0; i < N; i++)
	{
		vecCopy[i] = vector[i];
	}

	return vecCopy;
}

Matrix copyMatrix(Matrix& matrix) 
{
	Matrix matrixCopy;
	for (unsigned int i = 0; i < N; i++)
	{
		for (unsigned int j = 0; j < N; j++)
		{
			matrixCopy[i][j] = matrix[i][j];
		}
	}
	return matrixCopy;
}