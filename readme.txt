THIS COMPILER GENERATES x86-64 GNU ASSEMBLY

THE GENERATED ASSEMBLY WILL COMPILE WITH gcc assembler

Run Instructions:
    1. Run make
        This will generate output files for 5 test cases included
        This will also print symbol table corresponding to each test case.
    2. Finally to run assembly corresponding to any test file run command:
        ./test<i>.out where i is test file number to run (1-5) 
        example: ./test3.out

Invoking the compiler:
    ./compiler.out
        this will ask input file name, output quad file name and output assembly file name in the console itself

or  ./compiler.out input_file.c quads_file.out assembly_file.s
        to directly specify input and output file names as command-line arguments


Symbol Table:
    At run of make symbol table for each testfile is printed.
    each symbol table is given a unique id
    which is printed after function name.
    As a function may have more than one symbol table.

Note Regarding arrays:
    1. Note arrays are treated as pointers so size is 4 not block memory.
    2. array ref is calculated using pointer algebra
    3. a[5] is equivalent to *(a+5) hence no speacial operator for array deref.


Extra Features added:
    1. typeconversion within function calls supported
    2. Multidimensional arrays.
    3. Arrays as function parameters is allowed.

Limitations:
    1. To every array assigns a pointer.
    2. As told in assignment bit wise operators are not supported.

Notes on I/O functions:
    int readInt(int* n);
        Valid input format examples: 5, -6, 7, 0, 123 ...
        Invalid input format examples: a, 10f, - 5 (note space b/w - and 5), +7

