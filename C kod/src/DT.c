/** @file DT.c
 *  @brief A console driver.
 *
 *  This file contains all the functions needed for costructing working filter with direct 2 transposed realization.
 *
 *  @author Paula Franic
 *  @author Andro Coza
 *  @author Marin Parmac
 */

/* -- Includes -- */


/* libc includes. */
#include <stdio.h> /* for file function */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h> /* for allocating memory */
#include <assert.h>
#include <math.h> /* for math functions */

#include "DT.h"

struct IIR * createIIR(unsigned int const N)					// Ako ce se spajati IIR filti dodati jos da prima fylterType
{

	struct IIR *ptr = NULL;

	ptr = (struct IIR *) malloc (sizeof( struct IIR ));
	assert (NULL != ptr);
		if (NULL == ptr) return ptr;

	ptr->L = 0;
	ptr->coeffs = NULL;
	ptr->state = NULL;
	ptr->stateIndex = 0;
	ptr->filterType = 0;										// 0 -> direktna -- Treba doraditi fju ako ce se spajati iir filtri. Npr. ovdje treba staviti ptr->filterType = fylterType (ulazna vrijednost)!!!


	assert(NULL == ptr->coeffs);
	ptr->coeffs = (int16_t *) malloc (N * sizeof(int16_t));
	assert(NULL != ptr->coeffs);

	assert(NULL == ptr->state);
	ptr->state = (int16_t *) malloc (N * sizeof(int16_t));
	assert(NULL != ptr->state);

	if ((NULL == ptr->coeffs) || (NULL == ptr->state)) {
		deleteIIR (ptr);
		return NULL;
	};

	memset (ptr->coeffs, 0, N * sizeof(int16_t));
	memset (ptr->state, 0, N * sizeof(int16_t));

	ptr->L = N;

	return ptr;
};

void deleteIIR(struct IIR * iir)
{

		assert(NULL != iir);
			if (NULL == iir) return;

		if (NULL != iir->coeffs) {
			free (iir->coeffs);
			iir->coeffs = NULL;
				};

		if (NULL != iir->state) {
			free (iir->state);
			iir->state = NULL;
		};

		memset (iir->coeffs, 0, 0);
		memset (iir->state, 0, 0);

		free (iir);

}

int16_t readFirstWord(FILE *fp)
{
	assert(NULL != fp);
	char word[30];
	int16_t hex_word;

	fscanf(fp,"%s%*[^\n]",word);								// Uzme prvi string u nizu.
	hex_word = (int)strtol(word, NULL, 16);     				// String to integer.
	printf("word read is: %hX\n", hex_word);

	return hex_word;
}

struct IIR * getCoeffsAndInit_direct(char file_name[50]) 		// Prima naziv strukture.
{																// Ucitava koeficijente i inicijalizira filtar.

	struct IIR * iir = NULL;

	/* DIREKTNA
	 n
	 a
	amp_in
	a-ovi x n+1 od a_n do a_0
	b-ovi x n+1 od b_n do b_0
	amp_out
	p
	*/

	FILE *fp;
	int i = 0;

	fp = fopen(file_name, "r");									 // Otvori datoteku.


	if (fp == NULL) {
		printf("Nije uèitana datoteka s koeficijentima!!!\n");
		return iir;
		};
	// Ucitaj red filtra
	int16_t N = readFirstWord(fp);

	iir = createIIR(N);											// Inicijalizacija filtra s dohvacenim redom N.

	// Ucitaj preostale koeficijente
	for (i = 1; i <= (2*N + 5); i++)
	{

		iir->coeffs[i] = readFirstWord(fp);						// coeffs[1] = amp_in, coeffs[2] = a[N] ... coeffs[2N+4]=amp_out coeffs[2N+5]=p
	}
	fclose (fp);

	return iir;
}

void incrementStateIndex(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return;

	int stateIndex = (iir->stateIndex + 1);			// Cirkularni spremnik velicine reda N.
	assert((0 < stateIndex) && (stateIndex < iir->L));

	iir->stateIndex = stateIndex;
}

void decrementStateIndex(struct IIR * iir) {
	int i;
	assert(NULL != iir);
	if (NULL == iir) return;

	i = ((iir->stateIndex) - 1);

	assert((0 < i) && (i < iir->L));

	iir->stateIndex = i;
}

int16_t readState(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return 0;

	int i = iir->stateIndex;
	assert((0 <= i) && (i < iir->L));

	return (iir->state[i]);
}

void writeState(int16_t input, struct IIR * iir) {
	unsigned int i = iir->stateIndex;

	assert(NULL != iir);
		if (NULL == iir) return;

	iir->state[i] = input;
}

int16_t  IIRFilter_direct2_transposed(int16_t input,struct IIR * iir) {
	int16_t y = calculateValue(input,iir);
	updateState(input,y,iir);

return y;

}

int16_t calculateValue (int16_t input, struct IIR * iir) {
	assert ( (NULL != iir) || (iir->filterType == IIR_Direct) );
		if (NULL == iir) return 0;

		int N = iir->L;												// Red filtra.
		int16_t *coeffs_a = &(iir->coeffs[2]);
		int16_t *coeffs_b = &(iir->coeffs[N+3]);
		assert(NULL != coeffs_a || NULL != coeffs_b);

		int32_t x = (int32_t)(input) * (int32_t)(iir->coeffs[1]);// input * amp_in
		int32_t y = 0;

		int32_t zeroState = readState(iir);										// Postavi na inicijalno stanje. Na pocetku na zadnje.
		y = (int32_t)(zeroState + x*(*(coeffs_b)));
		if (*coeffs_a == 1)
		{
			// Ako je a0 = 1 -> pomaka udesno nema tj. dijelimo s 1.
		}
		else if (*coeffs_a == 2) y = (int32_t) (y >> 1);		// Ako je 2 -> desni pomak je za 1 tj. dijelimo s 2.
		else
		{														// Inace -> pomak za potenciju.
			y = (int32_t) (y >> (int32_t)log2((int32_t)(*coeffs_a)));
		}


		//y *= (int32_t)(iir->coeffs[2*N+4]);				// Izlaz, NE VALJA, DOHVATIT KOEFICIJENT IZLAZA
		y *= (iir->coeffs[2*N+4] << iir->coeffs[2*N+5]);
		return (int16_t)(y >> 15);
}

void updateState(int16_t input, int16_t output, struct IIR * iir) {
	assert ( (NULL != iir) || (iir->filterType == IIR_Direct) );
	if (NULL == iir) return;

	int N = iir->L;												// Red filtra.
	int16_t *coeffs_a = &(iir->coeffs[2]);
	int16_t *coeffs_b = &(iir->coeffs[N+3]);
	assert(NULL != coeffs_a || NULL != coeffs_b);
	int32_t currState;

	for (int i = 0; i < N-2; i++)
		{
			coeffs_a++;coeffs_b++;
			incrementStateIndex(iir);
			int32_t nextState = readState(iir);							// 0 + stanje[N]*b[N] +....+ stanje[1]*b[1]
			currState = nextState + *(coeffs_b)*input + *(coeffs_a)*output;
			decrementStateIndex(iir);
			writeState(currState,iir);
		}
	coeffs_a++;coeffs_b++;
	incrementStateIndex(iir);
	currState = *(coeffs_b)*input + *(coeffs_a)*output;
	writeState(currState);


}

int main() {
	struct IIR *iir;
	char file_coeffs[50]="words.txt";
	iir = getCoeffsAndInit_direct(file_coeffs);

	int16_t x=5;
	int16_t y = IIRFilter_direct2_transposed(x,iir);
	printf("a3 prije = %hX \n", iir->coeffs[2]);
	printf("a2 prije = %hX \n", iir->coeffs[3]);
	printf("a1 prije = %hX \n", iir->coeffs[4]);
	printf("a0 prije = %hX \n", iir->coeffs[5]);


	printf("kul = %hX \n", iir->coeffs[1]);
	printf("kiz = %hX \n", iir->coeffs[10]);
	printf("p = %hX \n", iir->coeffs[11]);

	printf("N = %hX ?? %d\n", iir->L, iir->coeffs[0]);

	puts("\n\n  ___________1.krug:\n");



return 0;
}
