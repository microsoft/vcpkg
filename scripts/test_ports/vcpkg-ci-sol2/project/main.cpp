// From README
#include <sol/sol.hpp>
#include <cassert>

int main() {
    sol::state lua;
    int x = 0;
    lua.set_function("beep", [&x]{ ++x; });
    lua.script("beep()");
    assert(x == 1);
}