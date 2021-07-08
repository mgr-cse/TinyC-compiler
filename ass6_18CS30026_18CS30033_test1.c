int readInt(int* n);
int printStr(char* s);
int printInt(int a);

// Tests
// arthmetic expressions
// global variables
// printInt, printStr, and readInt

int a, b;

// input/output
int main()
{
    printStr("Enter number a: ");
    readInt(&a);
    printStr("Enter number b: ");
    readInt(&b);
    printStr("Sum of a and b is: ");
    printInt(a+b);
    printStr("\n");
    printStr("Diff of a and b is: ");
    printInt(a-b);
    printStr("\n");
    printStr("Mult of a and b is: ");
    printInt(a*b);
    printStr("\n");
}