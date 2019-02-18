#ifndef _MYFFT_H_ 
#define _MYFFT_H_

#define u16_ft unsigned short 
#define PI_t 3.1415926
#define FFT_LEN 128



/*¸´Êý±äÁ¿*/
typedef struct
{
	char rel;
	char img;
}complex_t;





complex_t* fbk_seq(complex_t* sour);
complex_t* myfft(complex_t* sour);
complex_t comp_mul(complex_t mula, complex_t mulb);
complex_t* gen_wp(complex_t* sour);



#endif

