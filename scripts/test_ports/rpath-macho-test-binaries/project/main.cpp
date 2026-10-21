#include <stdio.h>

extern const char* getTestString();

int main()
{
    puts(getTestString());
}
