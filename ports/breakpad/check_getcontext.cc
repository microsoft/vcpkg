#include <ucontext.h>
#include <cstddef>

int main() {
    ucontext_t context;
    getcontext(&context);

    return 0;
}
