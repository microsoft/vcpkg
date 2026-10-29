#include <enchantum/enchantum.hpp>

#include <string_view>

enum class color
{
    red,
    green,
    blue
};

int main()
{
    return enchantum::to_string(color::green) == std::string_view{"green"} ? 0 : 1;
}
