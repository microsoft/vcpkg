#include <numa.h>

int main() {
    if (numa_available() < 0) return 1;
    return 0;
}
