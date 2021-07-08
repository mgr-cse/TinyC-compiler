int readInt(int* n);
int printStr(char* s);
int printInt(int a);

// Tests 
// Loops
// post increment

int main()
{
    int n, i;
    printStr("Enter number n >0: ");
    readInt(&n);
    int sum=0;
    for(i=0; i<=n; i++)
        sum=sum+i;
    printStr("Sum of first n number is: ");
    printInt(sum);
    printStr("\n");
}