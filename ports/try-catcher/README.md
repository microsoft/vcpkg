# TryCatcher
TryCatcher provides a modern C++ RAII mechanism to complete a sequence of operations, catch any and all exceptions that may occur, and throw a single, composite message when it goes out of scope.

In this way, all steps in the sequence will be tried regardless of any errors that may occur along the way. Any and all errors will be reported in a newline-separated message string when the TryCatcher goes out of scope and throws an exception. If no errors occur, TryCatcher goes out of scope without throwing an exception.

See the well-commented TryCatcher.h file for details and examples.
