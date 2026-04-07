#include "duk_bridge.h"
#include <cassert>
#include <iostream>

int main() {
    duk_context *ctx = duk_create_heap(nullptr, nullptr, nullptr, nullptr, nullptr);
    duk_eval_string(ctx, "function add(a, b) { return a + b; }");
    duk_eval_string(ctx, "add(1, 2)");
    int ret = duk_get_int(ctx, -1);
    std::cout << "add(1, 2) == " << ret << std::endl;
    assert(ret == 3);
    duk_destroy_heap(ctx);
    return 0;
}
