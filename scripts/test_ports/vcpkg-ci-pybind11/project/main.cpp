#include <pybind11/pybind11.h>

int mul(int i, int j) {
    return i * j;
}

PYBIND11_MODULE(example, m) {
    m.doc() = "vcpkg pybind11 test";
    m.def("mul", &mul, "Multiplies two numbers");
}
