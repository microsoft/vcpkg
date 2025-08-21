#include <iostream>
#include <toml++/toml.hpp>

int main(int argc, char** argv)
{
    if (argc < 2)
        return 1;

    try
    {
        toml::table tbl;
        tbl = toml::parse_file(argv[1]);
        std::cout << tbl << "\n";
    }
    catch (const toml::parse_error& err)
    {
        std::cerr << "Parsing failed: " << err << "\n";
        return 2;
    }

    return 0;
}
