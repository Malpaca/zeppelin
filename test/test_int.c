#include <stdio.h>
#include <stdlib.h>

int main(int argc, char ** argv){
    char * filename = argv[1];
    FILE * f = fopen(filename, "rb");
    int buf;
    while((fread(&buf, sizeof(unsigned int), 1, f))){
        printf("%d ", buf);
    }
    printf("\n");
    return 0;
}
