#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int cmpfunc( const void *a, const void *b) {
	return *(char *)a - *(char *)b;
}

int main(int argc, char ** argv){
	char fname[50];
    char buf [9999];
    int id = atoi(argv[1]);
    int line_len, i;
    sprintf(fname, "dna650MB/stuff_%d.dat", id);
	FILE * f = fopen(fname, "r");
    if (f == NULL){
        printf("can't open file: %s",fname);
        return -1;
    }
    int arr[4] = {0};
	while (fgets (buf, 9999, f)!=NULL ) {
		buf[strcspn(buf, "\r\n")] = '\0';
		line_len = strlen(buf);
        for (i=0; i< line_len; i++) {
			if (buf[i] == 'A') arr[0]+=1;
            if (buf[i] == 'C') arr[1]+=1;
			if (buf[i] == 'T') arr[2]+=1;
			if (buf[i] == 'G') arr[3]+=1;
        }
	}
    fclose(f);
    sprintf (fname, "output/count_%d", id);
	f = fopen(fname, "wb");
    if (f == NULL){
        printf("can't open file: %s",fname);
        return -1;
    }
    fwrite(arr, sizeof(int), 4, f);
	// printf("%d\n", a);
	return 0;
}
