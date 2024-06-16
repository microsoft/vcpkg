#include <stdio.h>

extern const char* getTestString();

int main()
{
    printf("%s\n", getTestString());
}
