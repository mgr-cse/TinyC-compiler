int readInt(int* n);
int printStr(char* s);
int printInt(int a);

// Tests 
// Nested symbol tables

int a;
void print()
{
    a=5;
    printStr("a in global scope is: ");
    printInt(a);
    printStr("\n");
}
int main()
{
    int a=7;
    {
        int a=11;
        printStr("a local nested one is: ");
        printInt(a);
        printStr("\n");
    }

    printStr("a local nested zero is: ");
    printInt(a);
    printStr("\n");

    print();

}