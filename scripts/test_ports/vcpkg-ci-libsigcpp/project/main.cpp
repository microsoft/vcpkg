#include <sigc++/sigc++.h>
#include <iostream>
#include <string>

void on_print(const std::string &str) {
    std::cout << str;
}

int main() {
    sigc::signal<void(const std::string &)> signal_print;
    signal_print.connect(sigc::ptr_fun(&on_print));
    signal_print.emit("hello world\n");
    return 0;
}
