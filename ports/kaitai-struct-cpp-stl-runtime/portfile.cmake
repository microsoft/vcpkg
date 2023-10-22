vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaitai-io/kaitai_struct_cpp_stl_runtime
    REF 0.10
    SHA512 27a0975edffe40a68784a3f5c639937fe70f634d97b7f3aae7d47db31ab4a81442c0707db562ac0775cf28012dc4172af52cc97bd02f2edecf713c57038f5b6d
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
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
