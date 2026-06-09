#include <void-numerics>

int main() {
    {
        char buffer[32];
        int64_t value = -9223372036854775807LL;
        auto result = vn::to_chars(buffer, buffer + sizeof(buffer), value);
    }
    {
        const char* input = "42abc";
        uint32_t value{};
        auto result = vn::from_chars(input, input + 5, value);
    }
    return 0;
}
