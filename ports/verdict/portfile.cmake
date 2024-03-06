vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/verdict
    REF fb582cf4fc04ecbd2bf423554325bda01231227a
    SHA512 137a386a6c11bf2738d752f995a8cf66661efedab72980a787893f8594066197dd8a966ed906d0d8b95cb05a2ec1b8e95906bb9214cf05604058719798ce7dbd
    HEAD_REF master
    PATCHES include.patch
            fix_osx.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERDICT_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/verdict" PACKAGE_NAME verdict)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

