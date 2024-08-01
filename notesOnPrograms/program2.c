// Initialize min and max differences
minMSB = 255;
minLSB = 255;
maxMSB = 0;
maxLSB = 0;

// Loop through the array in pairs
for (i = 0; i < 62; i += 2) {
    for (j = i + 2; j < 64; j += 2) {
        sign_mask = 0x80;
        signA = arr[i] & sign_mask;
        signB = arr[j] & sign_mask;

        if (signA != signB) {
            // Different signs, addition
            diffLSB = arr[i + 1] + arr[j + 1];
            
            carry = (diffLSB < arr[i + 1]) ? 1 : 0;
            diffMSB = arr[i] + arr[j] + carry;
        } else {
            // Same sign, subtraction
            if (arr[i] != arr[j]) {
                if (arr[i] > arr[j]) {
                    diffLSB = arr[i + 1] - arr[j + 1];
                    borrow = (diffLSB < 0) ? 1 : 0;
                    diffLSB += (borrow ? 256 : 0);
                    diffMSB = arr[i] - arr[j] - borrow;
                } else {
                    diffLSB = arr[j + 1] - arr[i + 1];
                    borrow = (diffLSB < 0) ? 1 : 0;
                    diffLSB += (borrow ? 256 : 0);
                    diffMSB = arr[j] - arr[i] - borrow;
                }
            } else {
                diffLSB = arr[i + 1] - arr[j + 1];
                if (diffLSB < 0) {
                    diffLSB += 256;
                    diffMSB = -1;
                } else {
                    diffMSB = 0;
                }
            }
        }

        // Update max difference
        if ((diffMSB > maxMSB) || (diffMSB == maxMSB && diffLSB > maxLSB)) {
            maxMSB = diffMSB;
            maxLSB = diffLSB;
        }

        // Update min difference
        if ((diffMSB < minMSB) || (diffMSB == minMSB && diffLSB < minLSB)) {
            minMSB = diffMSB;
            minLSB = diffLSB;
        }
    }
}

//When the sign is the same:
step1:
get mem[j+1]
aka lsb
flip the sign of mem[j+1] using xor by high and + 1
This +1 will toggle overflow flag
if we had overflow, branch to overflow error
//otherwise fall thru
get mem[i]
get mem[j]
flip the sign of mem[j]+1
add mem[i] + mem[j]
store result in diffMSB
//skip overflow error
//OVERFLOW
get mem[i]
get mem[j]
flip the sign of mem[j]+2 //adding 2 since we have the extra overflow
add mem[i] + mem[j]
store result in diffMSB
get mem[i+1] //Run by both regardless of overflow 
and mem[j+1]
flip the sign of mem[j+1] using xor by high and + 1
add mem[i+1]+mem[j+1]
load diffMSB
do abs(diffMSB, diffLSB)
store diffMSB
store diffLSB
