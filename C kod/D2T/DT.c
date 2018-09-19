/*!
 * @brief  Header file for direct 2 transposed filter realization
 * @author Paula Franić
 * @date   2018-09-19
 * @file   DT.c
 * @class Functions for IIR filter realization
*/



/* libc includes. */
#include <stdio.h> /* for file function */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h> /* for allocating memory */
#include <assert.h>
#include <math.h> /* for math functions */

#include "DT.h"

/*** FUCTIONS ***/

/** @brief Creates infinite pulse response structure with values of coefficients, filter order,
*
* Function allocates memory for filter structure, filter structure includes filter order, coefficient values, state values, state index value and filter type.
* After the memory for filter is allocated, we allocate memmory for coefficients and states.
* If memory couldn't be allocated we delete filter. We set memory values of coefficients and states to 0 and we set the order filter.
*
*  @param filter order
*  @return filter structure
*/
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

	//memset (ptr->coeffs, 0, N * sizeof(int16_t));
	memset (ptr->state, 0, N * sizeof(int16_t));

	ptr->L = N;

	return ptr;
};

/** @brief Deallocates the filter structure
*
* If the filter structure is already deallocated, then nothing is done. Otherwise, we check also for the coefficient and state allocation and if it isn't empty the we free memory, and set memory values to 0.
* After freeing coefficient and state memory, we deallocate filter structure memory.
*
*  @param iir filter structure
*/
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

/** @brief Reads values of filter structure from a file
*
* Function read first word in a row and converts it to integer value with strtol function from stdlib library.
*
*
*  @param fp file with values of filter structure
*  @return converted hex value to int16_t
*/
int16_t readFirstWord(FILE *fp)
{
	assert(NULL != fp);
	char word[30];
	int16_t hex_word;

	fscanf(fp,"%s%*[^\n]",word);								// Uzme prvi string u nizu.
	hex_word = (int16_t)strtol(word, NULL, 16);     	

	return hex_word;
}

/** @brief Initialization of a filter structure
*
* Function checks if file containing filter values could be open, if not, returns NULL. It needs to read first value from a file which is filter order that is needed to create and initialize filter structure. Then, coefficient values are assigned to coefficient array in filter structure.
* After we finish initializing, we close the file.
*
*  @param file_name file containing values of a filter
*  
*/
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

/** @brief increments value of state index to point on next state
*
*We check if the structure is empty. If not, we put incremented value of stateIndex in stateIndex.
*
*  @param iir filter structure
*/
void incrementStateIndex(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return;

	int stateIndex = (iir->stateIndex + 1);			
	assert((0 <= stateIndex) && (stateIndex < iir->L));

	iir->stateIndex = stateIndex;
}

/** @brief decrements value of state index to point on previous state
*
*We check if the structure is empty. If not, we put decremented value of stateIndex in stateIndex.
*
*  @param input value of a signal to be filtered
*  @return filtered value
*/
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

/** @brief Reads state on the given memory location
*
*Firstly, we check if filter exists, if not, we return 0. Otherwise we save value of stateIndex in varlable i and return the value of state on that given memory location.
*
*  @param iir filter structure
*  @return value of state
*/
int16_t readState(struct IIR * iir) {

	assert(NULL != iir);
	if (NULL == iir) return 0;

	int i = iir->stateIndex;
	assert((0 <= i) && (i < iir->L));

	return (iir->state[i]);
}

/** @brief Reads state on the given memory location
*
*Firstly, we check if filter exists, if not, we return 0. Otherwise we save value of stateIndex in varlable i and return the value of state on that given memory location.
*
*  @param iir filter structure
*  @return value of state
*/
int16_t readNextState(struct IIR * iir) {
    assert(NULL != iir);
	if (NULL == iir) return 0;

	int i = iir->stateIndex;
	assert((0 <= i) && (i < iir->L));

	return (iir->state[i+1]);    
}

/** @brief Writes input state on the given memory location
*
*  Firstly, we check if filter exists, if not, we returns. Otherwise we save value of stateIndex in varlable i and return the value of state on that given memory location.
*
*  @param iir filter structure
*  @param input value
*/
void writeState(int16_t input, struct IIR * iir) {
	unsigned int i = iir->stateIndex;

	assert(NULL != iir);
		if (NULL == iir) return;

	iir->state[i] = input;
}
/** @brief Calls functions for calculating output value and updating state values
 *
 *
 *  @param input value of a signal to be filtered
 *  @return filtered value
 */
int16_t  IIRFilter_direct2_transposed(int16_t input,struct IIR * iir) {
	int16_t y = calculateValue(input,iir);
	updateState(input,y,iir);

	return y;

}
/** @brief Calls functions for calculating output value and updating state values
 *
 *Check if the filter structure is empty. If not, assign values of filter order and coefficients to local variables of function. Multiply input value with amp_in and read first state. Multiply second coefficients of a numerator with input and add to zero state. Calculated value is output. Check for 1/a0 which potention is it and shift output value. After all, multiply output value with amp_out and shift it 15 times.
 *  @param input value of a signal to be filtered
 *  @param iir filter structure
 *  @return filtered value
 */
int16_t calculateValue (int16_t input, struct IIR * iir) {
    assert ( (NULL != iir) || (iir->filterType == IIR_Direct) );
	if (NULL == iir) return 0;

	int const N = iir->L;												// Red filtra.
	int16_t const * const coeffs_a = &(iir->coeffs[1]);
	int16_t const * const coeffs_b = &(iir->coeffs[N+2]);
	assert(NULL != coeffs_a || NULL != coeffs_b);
	
	int32_t x = input;// input * amp_in
	int32_t y = 0;
	int16_t const kul = iir->coeffs[0];
	int16_t state = readState(iir);
        int16_t const kiz = iir->coeffs[2*N+3];
        int16_t p = iir->coeffs[2*N+4];
                
        y = (int32_t)((int32_t)kul*(int32_t)x) >> 15;        
	y *= (int32_t)coeffs_b[0];
	y = y >> 15;// Postavi na inicijalno stanje. Na pocetku na zadnje.

        y += (int32_t)(state);
	if (coeffs_a[0] == 0)
	{
            // Ako je a0 = 0 -> pomaka udesno nema tj. dijelimo s 1.
	}
	else if (coeffs_a[0] == 2) y = (int32_t) (y >> 1);		// Ako je 2 -> desni pomak je za 1 tj. dijelimo s 2.
	else
	{														// Inace -> pomak za potenciju.
            y *= (int32_t) (y >> (int32_t)log2((coeffs_a[0])));
	}

	y *= (int32_t)(kiz) >> (15-p); // if za optimalni lijevi ili desni shift
                
	return (int16_t)(y);
}

/** @brief Updates value of states
 *
 *Check if the filter structure is empty. If not, assign values of filter order and coefficients to local variables of function. Increment pointer of coefficients and state. Read state at incremented state index (next state). Add multiplied numerator and input with multiplied denominator and output and next state. Decrement state index and write states. Repeat N - 2 times in for loop. For last state, exit for loop, increment coefficient and state pointers, multiply numerator with numerator and add with multiplication of denominator and output. Finally, write state.
 *  @param input value of a signal to be filtered
 *  @param iir filter structure
 *  @return filtered value
 */
void updateState(int16_t input, int16_t output, struct IIR * iir) {
	assert ( (NULL != iir) || (iir->filterType == IIR_Direct) );
	if (NULL == iir) return;

	int const N = iir->L;
	int16_t const *coeffs_a = &(iir->coeffs[1]);
	int16_t const *coeffs_b = &(iir->coeffs[N+2]);
	assert(NULL != coeffs_a || NULL != coeffs_b);
	int32_t currState = 0;
        int32_t nextState = 0;
        int32_t temp_b = 0;
        int32_t temp_a = 0;
	int i = 0;
        
	for (; i < N-1; i++)
	{
            nextState = readNextState(iir);
            coeffs_a++;coeffs_b++;
            temp_b = input * (int32_t)(*(coeffs_b));
            temp_a = output * (int32_t)(*(coeffs_a));
            currState = (int32_t)(temp_b - temp_a);
            currState = currState >> 15;
            currState = currState + nextState;
            writeState((int16_t)currState,iir);
            incrementStateIndex(iir);
	}
	coeffs_a++;coeffs_b++;
        temp_b = input * (int32_t)(*(coeffs_b));
        temp_a = output * (int32_t)(*(coeffs_a));       
	currState = (int32_t)(temp_b - temp_a);
	currState = currState >> 15;
	writeState((int16_t)currState,iir);
	resetStateIndex(iir);
}


int main() {
	struct IIR *iir;
	char file_coeffs[51]="words.txt";
	int i=0;
	char word[30];
	FILE *input, *output;
	int16_t signal, y;

	input = fopen("Test\\ULAZ_data.txt", "r");
	  if (NULL == input) {
	    printf("Nije uspijelo otvaranje datoteke s ulaznim podacima !");
	    return EXIT_FAILURE;
	  }else{ puts("otovrilo ulaz");
	  }
	  output = fopen("Test\\IZLAZ_data7.txt", "w");
	  if (NULL == output) {
	    printf("Nije uspijelo otvaranje datoteke s izlaznim podacima !");
	    return EXIT_FAILURE;
	  };

	  fseek(input, 0, SEEK_SET);

	  iir = getCoeffsAndInit_direct("words.txt"); //coeffs

	  for (i = 0; i < (10000); i++) {
	    fscanf(input, "%hX", &signal);
	    y = IIRFilter_direct2_transposed(signal, iir);

	    printf("Izlaz[%d] = %04hX\n",i,y);

	    fprintf(output, "%04hX\n", y);

	  };
     //coeffs


    deleteIIR(iir);
    fclose(input);
    fclose(output);

    system("pause");
}
