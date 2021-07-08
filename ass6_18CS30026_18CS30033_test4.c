int readInt(int* n);
int printStr(char* s);
int printInt(int a);

// tests arrays
// recursive buble sort
// tests pointers

void swap(int* a, int* b)
{
    int t= *a;
    *a= *b;
    *b= t;
}

void bubble_sort(int* a, int n)
{
    if(n==0)
        return;
    bubble_sort(a+1, n-1);
    int i;
    for(i=1; i<n; i++)
        if(a[i-1]>a[i])
            swap(a+i-1, a+i);
}

int main()
{
    int n, i;
    printStr("Enter size of array: ");
    readInt(&n);
    int a[1000];
    for(i=0; i<n; i++)
    {
        printStr("Enter a[");
        printInt(i);
        printStr("]: ");
        readInt(a+i);
    }
    bubble_sort(a, n);
    printStr("Sorted array is: ");
    for(i=0; i<n; i++)
    {
        printInt(a[i]);
        printStr(" ");
    }
    printStr("\n");
}