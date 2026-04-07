vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaitai-io/kaitai_struct_cpp_stl_runtime
    REF "${VERSION}"
    SHA512 fd537c5d45d4c53de54c31b9286ff1100f74d62458fa2bbfd0d10d9cfedeb638e20c8d89a683b934310244de1de1093dbf79a06ac56a4918032ee31f0b49cbd7
    HEAD_REF master
    PATCHES
        remove-werror.patch
)

set(STRING_ENCODING_TYPE "NONE")
if ("iconv" IN_LIST FEATURES)
    set(STRING_ENCODING_TYPE "ICONV")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS    
        -DSTRING_ENCODING_TYPE=${STRING_ENCODING_TYPE}
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
