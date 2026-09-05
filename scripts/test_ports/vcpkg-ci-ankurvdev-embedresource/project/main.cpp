#include <EmbeddedResource.h>
#include <exception>
#include <iostream>
#include <stdexcept>
#include <string_view>

DECLARE_RESOURCE_COLLECTION(testdata1);
DECLARE_RESOURCE_COLLECTION(testdata2);
DECLARE_RESOURCE_COLLECTION(testdata3);
DECLARE_RESOURCE(testdata3, main_cpp);

void verify_resource(ResourceLoader const& r)
{
    if (r.name() == L"main.cpp")
    {
#ifdef __cpp_lib_span
        if (r.template data<uint8_t>().size() != MAIN_CPP_FILE_SIZE) { throw std::runtime_error("r.data.len() != MAIN_CPP_FILE_SIZE"); }
#endif
#ifdef __cpp_lib_string_view
        if (r.string().size() != MAIN_CPP_FILE_SIZE) { throw std::runtime_error("r.string().size() != MAIN_CPP_FILE_SIZE"); }
#endif
    }
    else if (r.name() == L"CMakeLists.txt")
    {
#ifdef __cpp_lib_span
        if (r.template data<uint8_t>().size() != CMAKELISTS_TXT_FILE_SIZE)
        {
            throw std::runtime_error("r.data.len() != CMAKELISTS_TXT_FILE_SIZE");
        }
#endif
#ifdef __cpp_lib_string_view
        if (r.string().size() != CMAKELISTS_TXT_FILE_SIZE) { throw std::runtime_error("r.string().size() != CMAKELISTS_TXT_FILE_SIZE"); }
#endif
    }
    else { throw std::runtime_error("Unknown resource name"); }
}

int main(int argc, char* argv[])
try
{
    std::string_view res = LOAD_RESOURCE(testdata3, main_cpp).data;
    if (res.size() != MAIN_CPP_FILE_SIZE) { throw std::runtime_error("r.data.len() != MAIN_CPP_FILE_SIZE"); }

    auto resourceCollection1 = LOAD_RESOURCE_COLLECTION(testdata1);
    for (auto const r : resourceCollection1) { verify_resource(r); }

    auto resourceCollection2 = LOAD_RESOURCE_COLLECTION(testdata2);
    for (auto const r : resourceCollection2) { verify_resource(r); }

    auto resourceCollection3 = LOAD_RESOURCE_COLLECTION(testdata3);
    for (auto const r : resourceCollection2) { verify_resource(r); }

    return 0;
} catch (const std::exception& ex)
{
    std::cerr << "Failed: " << ex.what() << std::endl;
    return -1;
}