#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char ** argv){
	char fname[50];
    int arr [4] = {0};
    int buf[4];
    int read;
    FILE * f;
    for (int i = 0; i < 14; i++){
        sprintf (fname, "parallel_try/output/count_%d", i);
    	f = fopen(fname, "rb");
        while ((read = fread (buf,sizeof(int),4,f)) > 0) {
            for (int j=0; j< read; j++) {
                printf("%d:%d\n", i, buf[j]);
                arr[j] += buf[j];
            }
        }
        fclose(f);
    }
    sprintf (fname, "parallel_try/output/count_total");
	f = fopen(fname, "w");
    if (f == NULL){
        printf("can't open file: %s",fname);
        return -1;
    }
    fwrite(arr, sizeof(int), 4, f);
	// printf("%d\n", a);
	return 0;
}
