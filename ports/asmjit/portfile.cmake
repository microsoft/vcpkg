vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmjit
    REF 4a61c23ab65a8feb58d1bcdb7cbe8c8bdc36b7d1 # commited on 2024-06-05
    SHA512 ccc04655d031bd5a89d217aac85f6a8bdb756684257877de8df2162b2ec6e0d95cd7e01c0d46f817465fccb0fa52a4552d5034c48f361f2854f2e05aa32b7c89
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ASMJIT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DASMJIT_STATIC=${ASMJIT_STATIC}
 )

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/asmjit)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
