#include <iostream>
#include <ast.h>

int main() {
    // Initialize AST for the current thread
    astBegin;

    std::cout << "AST has been initialized successfully." << std::endl;

    // End the AST context
    astEnd;

    return 0;
}
