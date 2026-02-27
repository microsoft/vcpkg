#include <iostream>
#include <VMProtectSDK.h>

int main() {
    VMProtectBeginVirtualization("main");
    auto lang = "C++";
    std::cout << "Hello and welcome to " << lang << "!\n";

    for (int i = 1; i <= 5; i++) {
        std::cout << "i = " << i << std::endl;
    }
    VMProtectEnd();
    return 0;
}
