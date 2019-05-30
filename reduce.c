#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char ** argv){
	char fname[50];
    int buf [9999];
    FILE * f;
    for (int i = 0; i < 14; i++){
        sprintf (fname, "output/count_%d", i);
    	f = fopen(fname, "rb");
        while (fgets (buf, 9999, f)!=NULL ) {
            buf[strcspn(buf, "\r\n")] = '\0';
            line_len = strlen(buf);
            for (i=0; i< line_len; i++) {
                arr[buf[i] - 'a'] += 1;
            }
        }
        fclose(f);
    }
    sprintf (fname, "output/count_total");
	f = fopen(fname, "w");
    if (f == NULL){
        printf("can't open file: %s",fname);
        return -1;
    }
    fwrite(arr, sizeof(int), 4, f);
	// printf("%d\n", a);
	return 0;
}
