#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

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
void toLowerCase(char *str);
void removeComments(char *line);
unsigned int parseImmediate(char *str);
void trimWhitespace(char *str);

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
        removeComments(line);
        trimWhitespace(line);

        // Skip blank lines
        if (strlen(line) == 0) {
            continue;
        }

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
    if (!token) return 0;
    strcpy(opcode, token);
    toLowerCase(opcode);

    // Determine the opcode and parse accordingly
    if (strcmp(opcode, "xor") == 0 || strcmp(opcode, "and") == 0) {
        int op = (strcmp(opcode, "xor") == 0) ? XOR : AND;
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg3, token);

        machineCode = (op << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | getRegister(reg3);
    } else if (strcmp(opcode, "saddto") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        char signedAddition = (token[0] == '1') ? 1 : 0;
        token = strtok(NULL, " ");
        if (!token) return 0;
        char carryIn = (token[0] == '1') ? 1 : 0;
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg2, token);

        machineCode = (SADD << 6) | (signedAddition << 5) | (carryIn << 4) | (getRegister(reg1) << 2) | getRegister(reg2);
    } else if (strcmp(opcode, "mov") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(immediate, token);

        machineCode = (MOV << 6) | (getRegister(reg1) << 4) | parseImmediate(immediate);
    } else if (strcmp(opcode, "shift") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(immediate, token);

        machineCode = (SHIFT << 6) | (getRegister(reg1) << 4) | (parseImmediate(immediate) & 0x0F);
    } else if (strcmp(opcode, "blt") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg3, token);

        machineCode = (BLT << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | getRegister(reg3);
    } else if (strcmp(opcode, "str") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(immediate, token);

        machineCode = (STR << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | parseImmediate(immediate);
    } else if (strcmp(opcode, "ldr") == 0) {
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg1, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(reg2, token);
        token = strtok(NULL, " ");
        if (!token) return 0;
        strcpy(immediate, token);

        machineCode = (LDR << 6) | (getRegister(reg1) << 4) | (getRegister(reg2) << 2) | parseImmediate(immediate);
    }

    return machineCode;
}

unsigned int getRegister(char *reg) {
    toLowerCase(reg);
    if (strcmp(reg, "r0") == 0) return R0;
    if (strcmp(reg, "r1") == 0) return R1;
    if (strcmp(reg, "r2") == 0) return R2;
    if (strcmp(reg, "r3") == 0) return R3;
    return 0; // Default case, should never reach here if input is correct
}

void printBinary(FILE *file, unsigned int num, int bits) {
    for (int i = bits - 1; i >= 0; i--) {
        fprintf(file, "%d", (num >> i) & 1);
    }
}

void toLowerCase(char *str) {
    while (*str) {
        *str = tolower(*str);
        str++;
    }
}

void removeComments(char *line) {
    char *comment = strstr(line, "//");
    if (comment) {
        *comment = '\0';
    }
}

unsigned int parseImmediate(char *str) {
    if (str[0] == 'b') {
        return strtol(str + 1, NULL, 2); // Parse binary
    } else {
        return atoi(str); // Parse decimal
    }
}

void trimWhitespace(char *str) {
    char *end;

    // Trim leading space
    while (isspace((unsigned char)*str)) str++;

    if (*str == 0) { // All spaces?
        return;
    }

    // Trim trailing space
    end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned char)*end)) end--;

    // Write new null terminator character
    end[1] = '\0';
}
