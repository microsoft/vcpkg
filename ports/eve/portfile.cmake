message(WARNING "EVE requires a C++ 20 compliant compiler. GCC-11 and clang-12 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/eve
    REF v2022.09.0
    SHA512 ab5be8c897955e08e1aa192ac9dd90e310b2786a2f295b0d5a5d309fa8e621b66673668b9dbe2f683a5e2596d291b0521d80a8bb80f493ecb12e86ab5d830c7b
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/eve" RENAME copyright)
