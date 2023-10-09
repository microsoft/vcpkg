vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF b4c371fa0cbc4dcbaccc359ce9e957a22988fb34
    SHA512 1338271a6f9ffb3b8a8d4f2ec36a374ed84b3c91f789b607693c08cbeb38c4fdd813593f530ff94e841a095ff367a3ae8c5f5e7dbcb64e8f9044f6affdf24505
    HEAD_REF master
    PATCHES pkgconfig.patch
            fix-clang-cl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
