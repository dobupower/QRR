#include <stdio.h>
#include <stdlib.h>


int main(){
    
    int x[10] = { 17, 3, 52, 21, 26, 11, 34, 16, 44, 66 };
    int value,j;
    
    for(int i=1; i<10; i++){
        value=x[i];
        
        j=i;
        while( j>0 && x[j-1] > value ){
            x[j] = x[j-1]; j--;
        }
        x[j] = value;
    }
    
    for(int i=0; i<10; i++){
        printf("%d ", x[i]);
    }
    
    return 0;
}