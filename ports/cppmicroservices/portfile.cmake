vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CppMicroServices/CppMicroservices
    REF "v${VERSION}"
    SHA512 4743846a8ba45e6bd320c93bb3bd443b5dac16ea0bbf55bda6212e9200a40ee29031fd74c6141de4c6b5ef9ad3e70789d13fda25b40638547782d386a12dd7e2
    HEAD_REF development
    PATCHES
        werror.patch
        fix-thirdparty.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTOOLS_INSTALL_DIR:STRING=tools/cppmicroservices
        -DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices
        -DUS_USE_SYSTEM_GTEST=TRUE
        -DUS_BUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(NOT BUILD_SHARED_LIBS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()