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
#define AND     0b111
#define ADD     0b10000
#define SUB     0b10001
#define COPY    0b10010
#define ABS     0b10011
#define MOV     0b010
#define SHIFT   0b011
#define CMP     0b10100
#define STR     0b000
#define LDR     0b001
#define BLE     0b1010100
#define BLT     0b1010101
#define BEQ     0b1010110
#define BNE     0b1010111
#define BGE     0b1011000
#define BGT     0b1011010
#define B       0b1011011
#define BOF     0b1011111
#define ADD1    0b1011100
#define ADD2    0b1011101
#define SUB1    0b1011110
#define NOP     0b101100100

// Register identifiers (assuming you have 4 registers: R0, R1, R2, R3)
#define R0 0b00
#define R1 0b01
#define R2 0b10
#define R3 0b11

// Error codes
#define SUCCESS 0
#define ERROR_INVALID_OPCODE 1
#define ERROR_INVALID_REGISTER 2
#define ERROR_INVALID_IMMEDIATE 3
#define ERROR_MISSING_OPERAND 4

// Function prototypes
int parseInstruction(char *instruction, unsigned int *machineCode);
unsigned int getRegister(char *reg, int *error);
void printBinary(FILE *file, unsigned int num, int bits);
void toLowerCase(char *str);
void removeComments(char *line);
unsigned int parseImmediate(char *str, int *error);
void trimWhitespace(char *str);
void printError(int errorCode, int lineNum);

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
    int lineNum = 0;
    while (fgets(line, sizeof(line), inputFile)) {
        lineNum++;
        removeComments(line);
        trimWhitespace(line);

        // Skip blank lines
        if (strlen(line) == 0) {
            continue;
        }

        unsigned int machineCode;
        int error = parseInstruction(line, &machineCode);
        if (error != SUCCESS) {
            printError(error, lineNum);
            fclose(inputFile);
            fclose(outputFile);
            return 1;
        }

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

int parseInstruction(char *instruction, unsigned int *machineCode) {
    char opcode[10], reg1[10], reg2[10], reg3[10], immediate[10];
    int error = SUCCESS;
    *machineCode = 0;

    // Tokenize the instruction
    char *token = strtok(instruction, " ,");
    if (!token) return ERROR_INVALID_OPCODE;
    strcpy(opcode, token);
    toLowerCase(opcode);

    // Determine the opcode and parse accordingly
    if (strcmp(opcode, "xor") == 0 || strcmp(opcode, "and") == 0) {
        int op = (strcmp(opcode, "xor") == 0) ? XOR : AND;
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg2, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg3, token);

        *machineCode = (op << 6) | (getRegister(reg1, &error) << 4) | (getRegister(reg2, &error) << 2) | getRegister(reg3, &error);
    } else if (strcmp(opcode, "nop") == 0) {
        *machineCode = NOP;
    } else if (strcmp(opcode, "bof") == 0) {
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);

        *machineCode = (BOF << 9) | getRegister(reg1, &error);
    } else if (strcmp(opcode, "add") == 0 || strcmp(opcode, "sub") == 0 || strcmp(opcode, "copy") == 0 || strcmp(opcode, "abs") == 0) {
        int op = (strcmp(opcode, "add") == 0) ? ADD :
                 (strcmp(opcode, "sub") == 0) ? SUB :
                 (strcmp(opcode, "copy") == 0) ? COPY : ABS;
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg2, token);

        *machineCode = (op << 4) | (getRegister(reg1, &error) << 2) | getRegister(reg2, &error);
    } else if (strcmp(opcode, "mov") == 0) {
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(immediate, token);

        *machineCode = (MOV << 6) | (getRegister(reg1, &error) << 4) | parseImmediate(immediate, &error);
    } else if (strcmp(opcode, "shift") == 0) {
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(immediate, token);

        *machineCode = (SHIFT << 6) | (getRegister(reg1, &error) << 4) | (parseImmediate(immediate, &error) & 0x0F);
    } else if (strcmp(opcode, "cmp") == 0) {
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg2, token);

        *machineCode = (CMP << 4) | (getRegister(reg1, &error) << 2) | getRegister(reg2, &error);
    } else if (strcmp(opcode, "str") == 0 || strcmp(opcode, "ldr") == 0) {
        int op = (strcmp(opcode, "str") == 0) ? STR : LDR;
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg2, token);
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(immediate, token);

        *machineCode = (op << 6) | (getRegister(reg1, &error) << 4) | (getRegister(reg2, &error) << 2) | parseImmediate(immediate, &error);
    } else if (strcmp(opcode, "ble") == 0 || strcmp(opcode, "blt") == 0 || strcmp(opcode, "beq") == 0 || strcmp(opcode, "bne") == 0 ||
               strcmp(opcode, "bge") == 0 || strcmp(opcode, "bgt") == 0 || strcmp(opcode, "b") == 0) {
        int op = (strcmp(opcode, "ble") == 0) ? BLE :
                 (strcmp(opcode, "blt") == 0) ? BLT :
                 (strcmp(opcode, "beq") == 0) ? BEQ :
                 (strcmp(opcode, "bne") == 0) ? BNE :
                 (strcmp(opcode, "bge") == 0) ? BGE :
                 (strcmp(opcode, "bgt") == 0) ? BGT : B;
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);

        *machineCode = (op << 2) | getRegister(reg1, &error);
    } else if (strcmp(opcode, "add1") == 0 || strcmp(opcode, "add2") == 0 || strcmp(opcode, "sub1") == 0) {
        int op = (strcmp(opcode, "add1") == 0) ? ADD1 :
                 (strcmp(opcode, "add2") == 0) ? ADD2 : SUB1;
        token = strtok(NULL, " ,");
        if (!token) return ERROR_MISSING_OPERAND;
        strcpy(reg1, token);

        *machineCode = (op << 2) | getRegister(reg1, &error);
    } else {
        return ERROR_INVALID_OPCODE;
    }

    return error;
}

unsigned int getRegister(char *reg, int *error) {
    toLowerCase(reg);
    if (strcmp(reg, "r0") == 0) return R0;
    if (strcmp(reg, "r1") == 0) return R1;
    if (strcmp(reg, "r2") == 0) return R2;
    if (strcmp(reg, "r3") == 0) return R3;
    *error = ERROR_INVALID_REGISTER;
    return 0;
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

unsigned int parseImmediate(char *str, int *error) {
    if (str[0] == 'b') {
        return strtol(str + 1, NULL, 2); // Parse binary
    } else {
        char *end;
        unsigned int value = strtol(str, &end, 10); // Parse decimal
        if (*end != '\0') {
            *error = ERROR_INVALID_IMMEDIATE;
        }
        return value;
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

void printError(int errorCode, int lineNum) {
    switch (errorCode) {
        case ERROR_INVALID_OPCODE:
            fprintf(stderr, "Error: Invalid opcode at line %d\n", lineNum);
            break;
        case ERROR_INVALID_REGISTER:
            fprintf(stderr, "Error: Invalid register at line %d\n", lineNum);
            break;
        case ERROR_INVALID_IMMEDIATE:
            fprintf(stderr, "Error: Invalid immediate value at line %d\n", lineNum);
            break;
        case ERROR_MISSING_OPERAND:
            fprintf(stderr, "Error: Missing operand at line %d\n", lineNum);
            break;
        default:
            fprintf(stderr, "Error: Unknown error at line %d\n", lineNum);
            break;
    }
}
