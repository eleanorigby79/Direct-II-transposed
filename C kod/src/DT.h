/** @file DT.h
 *  @brief Header file containing declarations.
 *
 *  This file contains all the declarations of functions, structures and enumeration for direct 2 transposed filter realization.
 *
 *  @author Paula Franic
 *  @author Andro Coza
 *  @author Marin Parmac
 */

#ifndef DT_H_
#define DT_H_

enum filterType_enum;
struct IIR;

/** @brief Calls functions for calculating output value and updating state values
 *
 *
 *  @param input value of a signal to be filtered
 *  @return filtered value
 */
int16_t  IIRFilter_direct2_transposed(int16_t input,struct IIR * iir);
/** @brief Creates infinite pulse response structure with values of coefficients, filter order,
 *
 *Function allocates memory for filter structure, filter structure includes filter order, coefficient values, state values, state index value and filter type.
 *After the memory for filter is allocated, we allocate memmory for coefficients and states.
 *If memory couldn't be allocated we delete filter. We set memory values of coefficients and states to 0 and we set the order filter.
 *
 *  @param filter order
 *  @return filter structure
 */
struct IIR * createIIR(unsigned int const N);
/** @brief Calls functions for calculating output value and updating state values
 *
 *
 *  @param input value of a signal to be filtered
 *  @return filtered value
 */
int16_t readFirstWord(FILE *fp);
/** @brief Reads values of filter structure from a file
 *
 * Function read first word in a row and converts it to integer value with strtol function from stdlib library.
 *
 *
 *  @param fp file with values of filter structure
 *  @return converted hex value to int16_t
 */
struct IIR * getCoeffsAndInit_direct(char file_name[50]);
/** @brief Initialization of a filter structure
 *
 *Function checks if file containing filter values could be open, if not, returns NULL. It needs to read first value from a file which is filter order that is needed to create and initialize filter structure. Then, coefficient values are assigned to coefficient array in filter structure.
 *After we finish initializing, we close the file.
 *
 *  @param file_name file containing values of a filter
 *  @param iir filter structure
 */
void writeState(int16_t input, struct IIR * iir);
/** @brief Reads state on the given memory location
 *
 *Firstly, we check if filter exists, if not, we return 0. Otherwise we save value of stateIndex in variable i and return the value of state on that given memory location.
 *
 *  @param iir filter structure
 *  @return value of state
 */
int16_t readState(struct IIR * iir);
/** @brief Reads state on the given memory location
 *
 *Firstly, we check if filter exists, if not, we return 0. Otherwise we save value of stateIndex in variable i and return the value of the next state on that given memory location.
 *
 *  @param iir filter structure
 *  @return value of state
 */
int16_t readNextState(struct IIR * iir);
/** @brief decrements value of state index to point on previous state
 *
 *We check if the structure is empty. If not, we put decremented value of stateIndex in stateIndex.
 *
 *  @param input value of a signal to be filtered
 *  @return filtered value
 */
void decrementStateIndex(struct IIR * iir);
/** @brief increments value of state index to point on next state
 *
 *We check if the structure is empty. If not, we put incremented value of stateIndex in stateIndex.
 *
 *  @param iir filter structure
 */
void incrementStateIndex(struct IIR * iir);
/** @brief Deallocates the filter structure
 *
 *If the filter structure is already deallocated, then nothing is done. Otherwise, we check also for the coefficient and state allocation and if it isn't empty the we free memory, and set memory values to 0.
 *After freeing coefficient and state memory, we deallocate filter structure memory.
 *
 *  @param iir filter structure
 */
void deleteIIR(struct IIR * iir);
/** @brief Calls functions for calculating output value and updating state values
 *
 *Check if the filter structure is empty. If not, assign values of filter order and coefficients to local variables of function. Multiply input value with amp_in and read first state. Multiply second coefficients of a numerator with input and add to zero state. Calculated value is output. Check for 1/a0 which potention is it and shift output value. After all, multiply output value with amp_out and shift it 15 times.
 *  @param input value of a signal to be filtered
 *  @param iir filter structure
 *  @return filtered value
 */
int16_t calculateValue (int16_t input, struct IIR * iir);
/** @brief Updates value of states
 *
 *Check if the filter structure is empty. If not, assign values of filter order and coefficients to local variables of function. Increment pointer of coefficients and state. Read state at incremented state index (next state). Add multiplied numerator and input with multiplied denominator and output and next state. Decrement state index and write states. Repeat N - 2 times in for loop. For last state, exit for loop, increment coefficient and state pointers, multiply numerator with numerator and add with multiplication of denominator and output. Finally, write state.
 *  @param input value of a signal to be filtered
 *  @param iir filter structure
 *  @return filtered value
 */
void updateState(int16_t input, int16_t output, struct IIR * iir);

enum filterType_enum { 											/// Ako ce se spajati IIR filtri.
	IIR_Direct,													/// ptr->filterType = 0;
	IIR_Direct_transposed,										/// ptr->filterType = 1;
	IIR_Cascade,												// /ptr->filterType = 2;
	IIR_Parallel												/// ptr->filterType = 3;
};
/** @struct iir
 * @brief This structure is used for containing all the filter information in one place
 *
 * @var iir::L
 * L contains filter order
 * @var iir::coeffs
 * Contains amp_in, numerator, denominator, amp_out and p values for filter
 * @var iir::state
 * Contains state values for filter
 * @var iir::filterType
 * Contains type of filter (Direct, Direct transposed, Cascade or Parallel)
 * @var iir::stateIndex
 * Contains index value point to a current state
 *
 */
struct IIR{
	unsigned int L;  											///filter order
	int16_t *coeffs;											///coefficient array (amp_in, numerator, denominator, amp_out, p)
	int16_t *state;												///filter states
	enum filterType_enum filterType;							///types of filter
	unsigned int stateIndex;									///state pointer
};

#endif /* DT_H_ */
