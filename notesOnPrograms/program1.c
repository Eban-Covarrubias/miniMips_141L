//Pseudo code to base assembly on:
//first compute the max by checking each pair
max = 0;
min = 30;
for(int i = 0; i < 64; i += 2){
   for(int j = i+2; j < 64; j+=2){
         sum = 0;
         part = xor(arr[i], arr[j]);
         mask = 00000001
         for(int count = 0; count < 8; count ++){
           sum += and(mask, part);
           shiftLeft(part, 1);
         }
         part = xor(arr[i+1], arr[j+1]);
         mask = 00000001
         for(int count = 0; count < 8; count ++){
           sum += and(mask, part);
           shiftLeft(part, 1);
         }
       if(max < sum){
           max = sum;
       }
       if(sum < min){
           min = sum;
       }
  }
}