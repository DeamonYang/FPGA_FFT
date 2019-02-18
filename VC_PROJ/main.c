#include <stdio.h>
#include "math.h"
#include "myfft.h"

#define LEN FFT_LEN

int main(int argc, char *argv[])
{

	int i;

	FILE *fp;

	if ((fp = fopen("fftdate1.txt", "w")) == NULL)
	{
		printf("create file error\n");

	}

	complex_t *w = NULL;

	complex_t capdata[LEN];


	for (i = 0; i < LEN; i++)
	{
		capdata[i].rel  = cosf(20*PI_t/LEN*i)*120;

//		printf("%d\n", capdata[i].rel);

		fprintf(fp,"%d\n", capdata[i].rel);

		capdata[i].img = 0;
	}



	/*产生旋转因子*/
	gen_wp(capdata);

	/*fft 变换*/
	w = myfft(capdata);

	printf("\n\n\n\n");

	fprintf(fp,"\n\n\n\n");

	for (i = 0; i < LEN; i++)
	{
		printf("%d + %di\n", capdata[i].rel, capdata[i].img);

//		fprintf(fp,"%f + %fi\n", capdata[i].rel, capdata[i].img);
		fprintf(fp, "%d\n", sqrt(capdata[i].rel * capdata[i].rel + capdata[i].img*capdata[i].img));

	}



	fclose(fp);

	return 0;
}
