#include <EmbeddedResource.h>
#include <exception>
#include <iostream>
#include <stdexcept>
#include <string_view>

DECLARE_RESOURCE_COLLECTION(testdata1);
DECLARE_RESOURCE_COLLECTION(testdata2);
DECLARE_RESOURCE_COLLECTION(testdata3);
DECLARE_RESOURCE(testdata3, main_cpp);

void verify_resource(const ResourceLoader& r)
{
    auto check_size = [&](size_t expected_size, const std::string& error_message) {
        if (r.data<uint8_t>().size() != expected_size || r.string().size() != expected_size) {
            throw std::runtime_error(error_message);
        }
    };

    if (r.name() == L"main.cpp") {
        check_size(MAIN_CPP_FILE_SIZE, "r.data.len() != MAIN_CPP_FILE_SIZE or r.string().size() != MAIN_CPP_FILE_SIZE");
    } else if (r.name() == L"CMakeLists.txt") {
        check_size(CMAKELISTS_TXT_FILE_SIZE, "r.data.len() != CMAKELISTS_TXT_FILE_SIZE or r.string().size() != CMAKELISTS_TXT_FILE_SIZE");
    } else {
        throw std::runtime_error("Unknown resource name");
    }
}

int main(int argc, char* argv[])
{
    try {
        std::string_view res = LOAD_RESOURCE(testdata3, main_cpp).data;
        if (res.size() != MAIN_CPP_FILE_SIZE) {
            throw std::runtime_error("r.data.len() != MAIN_CPP_FILE_SIZE");
        }

        auto resourceCollection1 = LOAD_RESOURCE_COLLECTION(testdata1);
        for (const auto& r : resourceCollection1) {
            verify_resource(r);
        }

        auto resourceCollection2 = LOAD_RESOURCE_COLLECTION(testdata2);
        for (const auto& r : resourceCollection2) {
            verify_resource(r);
        }

        auto resourceCollection3 = LOAD_RESOURCE_COLLECTION(testdata3);
        for (const auto& r : resourceCollection3) {
            verify_resource(r);
        }

        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "Failed: " << ex.what() << std::endl;
        return -1;
    }
}
