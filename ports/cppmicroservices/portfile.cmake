vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CppMicroServices/CppMicroservices
    REF "v${VERSION}"
    SHA512 4743846a8ba45e6bd320c93bb3bd443b5dac16ea0bbf55bda6212e9200a40ee29031fd74c6141de4c6b5ef9ad3e70789d13fda25b40638547782d386a12dd7e2
    HEAD_REF development
    PATCHES
        werror.patch
        fix_strnicmp.patch
        remove-wx.patch
)

#nowide download
vcpkg_from_github(
    OUT_SOURCE_PATH NOWIDE_SOURCE_PATH
    REPO boostorg/nowide
    REF 02f40f0b5f5686627fcddae93ff88ca399db4766
    SHA512 e68e0704896726c7a94b8ace0e03c5206b4c7acd23a6b05f6fb2660abe30611ac6913cf5fab7b57eaff1990a7c28aeee8c9f526b60f7094c0c201f90b715d6c6
    HEAD_REF develop
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/boost/nowide")
file(RENAME "${NOWIDE_SOURCE_PATH}" "${SOURCE_PATH}/third_party/boost/nowide")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTOOLS_INSTALL_DIR:STRING=tools/cppmicroservices
        -DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices
        -DUS_USE_SYSTEM_GTEST=TRUE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(NOT BUILD_SHARED_LIBS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()