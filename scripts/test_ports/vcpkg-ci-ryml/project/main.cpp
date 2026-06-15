#include <ryml/ryml.hpp>
#include <ryml/ryml_std.hpp>

int main() {
    char yml_buf[] = "{foo: 1, bar: [2, 3], john: doe}";
    ryml::Tree tree = ryml::parse_in_place(ryml::to_substr(yml_buf));
    ryml::ConstNodeRef root = tree.rootref();
    if (!root.is_map()) return 1;
    if (!root.has_child("foo")) return 2;
    int foo = 0;
    root["foo"] >> foo;
    if (foo != 1) return 3;
    return 0;
}
