#include "myfft.h"
#include "math.h"
#include "stdlib.h"
#include "stdio.h"

unsigned short my_fpga_wnp[] = { 0x7f00, 0x7ef4, 0x7de7, 0x7adb, 0x75cf, 0x70c4, 0x6ab9, 0x62af, 0x5aa6, 0x519e, 0x4796, 0x3c90, 0x318b, 0x2586, 0x1983, 0x0c82, 0x0081, 0xf482,
0xe783, 0xdb86, 0xcf8b, 0xc490, 0xb996, 0xaf9e, 0xa6a6, 0x9eaf, 0x96b9, 0x90c4, 0x8bcf, 0x86db, 0x83e7, 0x82f4, 0x8100, 0x820c, 0x8319, 0x8625, 0x8b31,
0x903c, 0x9647, 0x9e51, 0xa65a, 0xaf62, 0xb96a, 0xc470, 0xcf75, 0xdb7a, 0xe77d, 0xf47e, 0x007f, 0x0c7e, 0x197d, 0x257a, 0x3175, 0x3c70, 0x476a, 0x5162,
0x5a5a, 0x6251, 0x6a47, 0x703c, 0x7531, 0x7a25, 0x7d19, 0x7e0c, };
static complex_t w[FFT_LEN];
/*
*@功 能：实现序列倒叙
*@输 入：sour -- 序列  len -- 序列长度
*@返回值：变换后的序列地址（等于输入原序列地址）
*/
complex_t* fbk_seq(complex_t* sour)
{
	u16_ft M;
	u16_ft i, j = 0, t;
	complex_t temp;

	u16_ft len = FFT_LEN;

	/*判断为多少位二进制数*/
	M = (u16_ft)log2(len);


	for (i = 1; i < len - 1; i++)
	{
		j = 0;
		/*计算倒叙下标*/
		for (t = 0; t < M; t++)
		{
			j = j << 1;

			if ((i >> t) & 0x01)
			{
				j = j | 0x01;
			}
		}

		/*只对 i 小于j 的序列交换 防止交换之前交换过的序列*/
		if (i < j)
		{
			temp = sour[i];

			sour[i] = sour[j];

			sour[j] = temp;
		}
	}
	return sour;
}

/*
*@功 能：实现序列fft
*@输 入：sour -- 序列  len -- 序列长度
*@返回值：变换后的序列地址（等于输入原序列地址）
*/

complex_t* myfft(complex_t* sour)
{
	unsigned short M ,L,B,J,P,K,N;

	complex_t butterfly;

	complex_t* W = w;

	u16_ft len = FFT_LEN;


	N = len;

	M = (unsigned short)log2(len);

	/*倒序*/
	fbk_seq(sour);
	printf("倒序\n");
	for (int i = 0; i < FFT_LEN; i++)
		printf("%03d %03d\r\n",i,sour[i].rel);




	int BTL = 8;
	int ADL = 1;

	for (L = 1; L <= M; L++)
	{
		printf("LLLL = %d\r\n\n\n",L);
		B = 1 << (L - 1);

		for (J = 0; J <= B - 1; J++)
		{
			P = J * (1 << (M - L));

			for (K = J; K <= N - 1; K = K + (1 << L))
			{
				butterfly.rel = (sour[K + B].rel * W[P].rel - sour[K + B].img * W[P].img)>>BTL;																					 
				butterfly.img = (sour[K + B].rel * W[P].img + sour[K + B].img * W[P].rel)>>BTL;

				sour[K + B].img = (sour[K].img - butterfly.img)>>ADL;
				sour[K + B].rel = (sour[K].rel - butterfly.rel)>>ADL;

				sour[K].img = (sour[K].img + butterfly.img)>>ADL;
				sour[K].rel = (sour[K].rel + butterfly.rel)>>ADL;

				//printf("bfnum :  %d   %d  %d   %d  %d   %d  %d   %d\r\n", 
				//	K, P, W[P].rel, W[P].img, sour[K].rel, sour[K].img, sour[K + B].rel, sour[K + B].img);

			}
		
		}

	}

}

/*生成旋转因子*/
complex_t* gen_wp(complex_t* sour)
{
	static complex_t* wp  = w;

	unsigned short J , i ;

	float st, sp;

	u16_ft len = FFT_LEN;

	J = len / 2;




	/*旋转因子角度步进值*/
	sp = 2 * PI_t / len;

	st = 0;

	for (i = 0; i < len; i++)
	{
		st = sp * i;

		//wp[i].rel = cosf(st) * 127 - 0.5;

		//wp[i].img = -sinf(st) * 127 - 0.5;
		
		wp[i].rel = (unsigned char)((my_fpga_wnp[i] >>8)&(0xFF));

		wp[i].img = (unsigned char)((my_fpga_wnp[i] )&(0xFF));

//		printf("%02x%02x\r\n", (unsigned char)wp[i].rel, (unsigned char)wp[i].img);
	}


	return wp;

}


/*复数乘法*/
complex_t comp_mul( complex_t mula, complex_t mulb)
{
	complex_t res;

	res.rel = mula.rel * mula.rel - mula.img * mulb.img ;

	res.img = mula.rel * mulb.img + mula.img * mulb.rel;

	return res;

}


