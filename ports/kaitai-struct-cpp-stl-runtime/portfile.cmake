vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaitai-io/kaitai_struct_cpp_stl_runtime
    REF ${VERSION}
    SHA512 4efc2aa36662e35f6e23e2dbe300163c79740eb8b741742ee7c6a2510a4d5e1b336a711a59d6bac587456a031c4512155db5e311357fc49ad49cd5130761d2c0
    HEAD_REF master
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
