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

#define U 500

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
	ptr->coeffs = (int16_t *) malloc ((2*N+5) * sizeof(int16_t));
	assert(NULL != ptr->coeffs);

	assert(NULL == ptr->state);
	ptr->state = (int16_t *) malloc (N * sizeof(int16_t));
	assert(NULL != ptr->state);

	if ((NULL == ptr->coeffs) || (NULL == ptr->state)) {
		deleteIIR (ptr);
		return NULL;
	};

	memset (ptr->coeffs, 0, (2*N+5) * sizeof(int16_t));
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



		free (iir);

}

int16_t readFirstWord(FILE *fp)
{
	assert(NULL != fp);
	char word[30];
	int16_t hex_word;

	fscanf(fp,"%s%*[^\n]",word);								// Uzme prvi string u nizu.
	hex_word = (int)strtol(word, NULL, 16);     	

	return hex_word;
}

struct IIR * getCoeffsAndInit_direct(char * file_name) 		// Prima naziv strukture.
{																// Ucitava koeficijente i inicijalizira filtar.

	struct IIR * iir = NULL;

	/* DIREKTNA
	n
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
		printf("Nije ucitana datoteka s koeficijentima!!!\n");
		return iir;
		};
	// Ucitaj red filtra
	int16_t N = readFirstWord(fp);

	iir = createIIR(N);											// Inicijalizacija filtra s dohvacenim redom N.

	// Ucitaj preostale koeficijente
	for (i = 0; i < (2*N + 5); i++)
	{

		iir->coeffs[i] = readFirstWord(fp);						// coeffs[1] = amp_in, coeffs[2] = a[N] ... coeffs[2N+4]=amp_out coeffs[2N+5]=p
	}
	fclose (fp);

	return iir;
}

void incrementStateIndex(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return;

	int stateIndex = (iir->stateIndex + 1);			
	assert((0 <= stateIndex) && (stateIndex < iir->L));

	iir->stateIndex = stateIndex;
}

void decrementStateIndex(struct IIR * iir) {
	int i;
	assert(NULL != iir);
	if (NULL == iir) return;

	i = ((iir->stateIndex) - 1);

	assert((0 <= i) && (i < iir->L));

	iir->stateIndex = i;
}

void resetStateIndex(struct IIR * iir) {
	assert(NULL != iir);
		if (NULL == iir) return;

		iir->stateIndex = 0;
}

int16_t readState(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return 0;

	int i = iir->stateIndex;
	assert((0 <= i) && (i < iir->L));

	return (iir->state[i]);
}

int16_t readNextState(struct IIR * iir) {
    assert(NULL != iir);
	if (NULL == iir) return 0;

	int i = iir->stateIndex;
	assert((0 <= i) && (i < iir->L));

	return (iir->state[i+1]);    
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

		int const N = iir->L;												// Red filtra.
		int16_t const * const coeffs_a = &(iir->coeffs[1]);
		int16_t const * const coeffs_b = &(iir->coeffs[N+2]);
		assert(NULL != coeffs_a || NULL != coeffs_b);

		int32_t x = input;// input * amp_in
		int32_t y = 0;
		int16_t kul = iir->coeffs[0];
		int16_t state = readState(iir);

                int16_t p = iir->coeffs[2*N+4];
                
		x *= kul;
		x = x >> 15;// Postavi na inicijalno stanje. Na pocetku na zadnje.
		y = x * (int32_t)(coeffs_b[0]);
                y = y >> 15;
                y += (int32_t)(state);
		if (*coeffs_a == 1)
		{
			// Ako je a0 = 1 -> pomaka udesno nema tj. dijelimo s 1.
		}
		else if (*coeffs_a == 2) y = (int32_t) (y >> 1);		// Ako je 2 -> desni pomak je za 1 tj. dijelimo s 2.
		else
		{														// Inace -> pomak za potenciju.
			y *= (int32_t) (y >> (int32_t)log2((*coeffs_a)));
		}

		y *= (int32_t)(iir->coeffs[2*N+3]); // if za optimalni lijevi ili desni shift
                
                if(p > 15) {
                    p = p - 15;
                    y = y << p;
                }
                else if(p < 15) {
                    p = 15 - p;
                    y = y >> p;
                }

		return (int16_t)y;
}

void updateState(int16_t input, int16_t output, struct IIR * iir) {
	assert ( (NULL != iir) || (iir->filterType == IIR_Direct) );
	if (NULL == iir) return;

	int const N = iir->L;
	int16_t const *coeffs_a = &(iir->coeffs[1]);
	int16_t const *coeffs_b = &(iir->coeffs[N+2]);
	assert(NULL != coeffs_a || NULL != coeffs_b);
	int32_t currState = 0;
        int32_t nextState = 0;
	int i = 0;
        int32_t temp_b = 0;
        int32_t temp_a = 0;
	for (; i < N-1; i++)
		{
			nextState = readNextState(iir);
			coeffs_a++;coeffs_b++;
                        temp_b = input * (*(coeffs_b));
                        temp_a = output * (*(coeffs_a));
			currState = (int32_t)(temp_b + temp_a);
                        currState = currState >> 15;
			currState = currState + nextState;
			writeState((int16_t)currState,iir);
			incrementStateIndex(iir);
		}
	coeffs_a++;coeffs_b++;
        temp_b = input * (*(coeffs_b));
        temp_a = output * (*(coeffs_a));       
	currState = (int32_t)(temp_b + temp_a);
	currState = currState >> 15;
	writeState((int16_t)currState,iir);
	resetStateIndex(iir);
}

int main() {
	struct IIR *iir;
	char file_coeffs[51]="words.txt";
	int i=0;
	char word[30];
	FILE *fp;
	int x[U]={0};
	int16_t y[U] = {0};
	iir = getCoeffsAndInit_direct(file_coeffs);

	fp = fopen("sin.txt", "r");
	for(; i<U; i++) {

		fscanf(fp,"%s%*[^\n]",word);
		x[i] = (int)strtol(word, NULL, 16);
	}
	i=0;
	fclose(fp);
        fp=fopen("output.txt","w");
	while(i<U) {

		y[i] = IIRFilter_direct2_transposed((int16_t)x[i],iir);
		fprintf(fp,"%d\n", y[i]);
		i++;

	}
        fclose(fp);
        deleteIIR(iir);
        
return 0;
}
