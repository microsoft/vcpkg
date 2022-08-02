message(WARNING "EVE requires a C++ 20 compliant compiler. GCC-11 and clang-12 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/eve
    REF v2021.10.0
    SHA512 bdac483d07c968cfe2cd2e0f26df68f0e3b6cd83fbfe4b89650dc58fb534fd37c5540682283a2ee29a82e87bdfc678beac3651e40cde5b4cf30c20ea8304c72c
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/eve" RENAME copyright)
