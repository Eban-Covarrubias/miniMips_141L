//Note that operands are stored in 0-63
//Each mem slot holds 8 bits
//Start by multipying LSBs

for(i = 0; i < 64; i+= 4){
    //note, mem[i] = Ahi, mem[i+1] = Alo
    // mem[i+2] = Bhi, mem[i+3] = Blo
    mem[i+64] = 0;
    mem[i+65] = 0;
    mem[i+66] = 0;
    mem[i+67] = 0;


    resltLowlo1, carry = Low_mult(mem[i+1],mem[i+3]); //loop by 8 bit subroutine 1
    mem[i+67] = resltLowhi1 //First quarter done

    mem[i+66] = carry
    mem[i+66] += High_mult(mem[i+1], mem[i+3]); //loop by 8 bit subroutine 2


    mem[i+66] += Low_mult(mem[i],mem[i+3]); //loop by 8 bit subroutine 3
    carry = Low_mult_carry(mem[i],mem[i+3]); 

    mem[i+65] = carry;
    mem[i+65] += High_mult(mem[i], mem[i+3]); //loop by 8 bit subroutine 4
    carry = High_mult_carry(mem[i], mem[i+3]);
    mem[i+64] = carry

    mem[i+66] += Low_mult(mem[i+1],mem[i+2]); //loop by 8 bit subroutine 5
    carry = Low_mult_carry(mem[i+1],mem[i+2]); //Done with second quarter
    mem[i+65] += carry //add any carry bits
    carry = overflow?//check for overflow
    if(carry)
        mem[i+64] += 1;

        
    mem[i+65] += High_mult(mem[i+1], mem[i+2]); //loop by 8 bit subroutine 6
    carry = High_mult_carry(mem[i+1], mem[i+2]);
    mem[i+64] += carry;


    mem[i+65] += Low_mult(mem[i],mem[i+2]); //loop by 8 bit subroutine 7 
    carry =  Low_mult_carry(mem[i],mem[i+2]); //Done with third quarter 8

    mem[i+64] += carry;
    mem[i+64] += High_mult(mem[i], mem[i+2]); //loop by 8 bit subroutine
}
//let mem[128]=carry, mem[129]=i, mem[130]=j, mem[131]=shiftingOpA, mem[132]=shiftingOpB
