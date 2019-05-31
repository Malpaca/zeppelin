#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char ** argv){
	char fname[50];
    char buf [9999];
    int id = atoi(argv[1]);
    int line_len, i;
    sprintf(fname, "parallel_try/small_input/stuff_%d.txt", id);
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
            arr[buf[i] - 'a'] += 1;
        }
	}
    fclose(f);
    sprintf (fname, "parallel_try/output/count_%d", id);
	f = fopen(fname, "wb");
    if (f == NULL){
        printf("can't open file: %s",fname);
        return -1;
    }
    fwrite(arr, sizeof(int), 4, f);
	// printf("%d\n", a);
	return 0;
}
