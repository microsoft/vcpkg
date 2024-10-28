vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaitai-io/kaitai_struct_cpp_stl_runtime
    REF ${VERSION}
    SHA512 53b26627e281a12b6c1d217e8b439aba7dabf6fc55d3edc27e70f7757851f060f4039db3a16c48c5c60a715671b855b51e527f154df7d94547943f865c9d4b9a
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
