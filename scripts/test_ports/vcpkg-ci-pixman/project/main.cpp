#include <iostream>
#include <pixman.h>

int main() {
    const char* version = pixman_version_string();
    std::cout << "Pixman version: " << version << "\n";

    return 0;
}
