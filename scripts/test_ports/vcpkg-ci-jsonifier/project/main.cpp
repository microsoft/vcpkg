#include <jsonifier>

#include <string>

struct record
{
    int value{};
    std::string name{};
};

template<>
struct jsonifier::core<record>
{
    using value_type = record;
    static constexpr auto parseValue = createValue<&value_type::value, &value_type::name>();
};

int main()
{
    jsonifier::jsonifier_core<> parser;
    record input{};
    if (!parser.parseJson(input, R"({"value":42,"name":"vcpkg"})"))
    {
        return 1;
    }

    std::string output;
    parser.serializeJson(input, output);
    return input.value == 42 && input.name == "vcpkg" && !output.empty() ? 0 : 2;
}
