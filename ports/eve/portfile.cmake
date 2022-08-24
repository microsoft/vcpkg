message(WARNING "EVE requires a C++ 20 compliant compiler. GCC-11 and clang-12 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/eve
    REF v2022.03.0
    SHA512 9ca2cb69a179bf05046696ba83a1cea4e558a0a883ca1d664effc2564e07123f631fc3885256d0dede09c8ec10b23a3feca0ec19ed9c73000cf698384ab4663d
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/eve" RENAME copyright)
