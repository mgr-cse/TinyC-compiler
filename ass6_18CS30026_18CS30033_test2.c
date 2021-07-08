int readInt(int* n);
int printStr(char* s);
int printInt(int a);

// Tests control flow
// if statemens
// functions
// local variables
// recursion

int fib(int n)
{
    if(n<2)
        return n;
    return fib(n-1)+fib(n-2);
}

// input/output
int main()
{
    int n;
    printStr("Enter n (0<=n<=30): ");
    readInt(&n);
    printStr("nth Fibbonaci number is: ");
    printInt(fib(n));
    printStr("\n");
}