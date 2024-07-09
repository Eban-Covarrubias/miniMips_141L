#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
To use this assembler, use the following lines:

gcc assembler.c -o assembler
./assembler instructions.txt output.txt

or for binary output use the -b flag, ex:
./assembler instructions.txt output.txt -b

*/

// Opcodes
#define XOR     0b110
#define AND     0b110
#define SADD    0b100
#define MOV     0b010
#define SHIFT   0b011
#define BLT     0b101
#define STR     0b000
#define LDR     0b001

// Register identifiers (assuming you have 4 registers: R0, R1, R2, R3)
#define R0 0b00
#define R1 0b01
#define R2 0b10
#define R3 0b11

// Function prototypes
unsigned int parseInstruction(char *instruction);
unsigned int getRegister(char *reg);
void printBinary(FILE *file, unsigned int num, int bits);

int main(int argc, char *argv[]) {
    if (argc < 3 || argc > 4) {
        fprintf(stderr, "Usage: %s <input file> <output file> [-b]\n", argv[0]);
        return 1;
    }

    int binaryOutput = 0;
    if (argc == 4 && strcmp(argv[3], "-b") == 0) {
        binaryOutput = 1;
    }

    FILE *inputFile = fopen(argv[1], "r");
    if (!inputFile) {
        perror("Could not open input file");
        return 1;
    }

    FILE *outputFile = fopen(argv[2], "w");
    if (!outputFile) {
        perror("Could not open output file");
        fclose(inputFile);
        return 1;
    }

    char line[256];
    while (fgets(line, sizeof(line), inputFile)) {
        unsigned int machineCode = parseInstruction(line);
        if (binaryOutput) {
            printBinary(outputFile, machineCode, 9);
            fprintf(outputFile, "\n");
        } else {
            fprintf(outputFile, "%03x\n", machineCode); // Write as hexadecimal
        }
    }

    fclose(inputFile);
    fclose(outputFile);
    return 0;
}

unsigned int parseInstruction(char *instruction) {
    char opcode[10], reg1[10], reg2[10], reg3[10], immediate[10];
    unsigned int machineCode = 0;

    // Tokenize the instruction
    char *token = strtok(instruction, " ");
    strcpy(opcode, token);

    // Determine the opcode and parse accordingly
    if (strcmp(opcode, "Xor") == 0 || strcmp(opcode, "And") == 0) {
        int op = (strcmp(opcode, "Xor") == 0) ? XOR : AND;
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        strcpy(reg3, token);

        machineCode = (op << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | getRegister(reg3);
    } else if (strcmp(opcode, "Saddto") == 0) {
        token = strtok(NULL, " ");
        char signedAddition = (token[0] == '1') ? 1 : 0;
        token = strtok(NULL, " ");
        char carryIn = (token[0] == '1') ? 1 : 0;
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(reg2, token);

        machineCode = (SADD << 6) | (signedAddition << 5) | (carryIn << 4) | (getRegister(reg1) << 2) | getRegister(reg2);
    } else if (strcmp(opcode, "Mov") == 0) {
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(immediate, token);

        machineCode = (MOV << 6) | (getRegister(reg1) << 4) | atoi(immediate);
    } else if (strcmp(opcode, "Shift") == 0) {
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(immediate, token);

        machineCode = (SHIFT << 6) | (getRegister(reg1) << 4) | (atoi(immediate) & 0x0F);
    } else if (strcmp(opcode, "blt") == 0) {
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        strcpy(reg3, token);

        machineCode = (BLT << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | getRegister(reg3);
    } else if (strcmp(opcode, "Str") == 0) {
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        strcpy(immediate, token);

        machineCode = (STR << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | atoi(immediate);
    } else if (strcmp(opcode, "ldr") == 0) {
        token = strtok(NULL, " ");
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        strcpy(immediate, token);

        machineCode = (LDR << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | atoi(immediate);
    }

    return machineCode;
}

unsigned int getRegister(char *reg) {
    if (strcmp(reg, "R0") == 0) return R0;
    if (strcmp(reg, "R1") == 0) return R1;
    if (strcmp(reg, "R2") == 0) return R2;
    if (strcmp(reg, "R3") == 0) return R3;
    return 0; // Default case, should never reach here if input is correct
}

void printBinary(FILE *file, unsigned int num, int bits) {
    for (int i = bits - 1; i >= 0; i--) {
        fprintf(file, "%d", (num >> i) & 1);
    }
}
