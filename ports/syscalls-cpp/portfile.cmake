vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sapdragon/syscalls-cpp
    REF "v${VERSION}"             
    SHA512 47709c046b1b8ce629c8aa879164b49c918150fe5c1f6e3349b12ba1ffceb99557ee2357ec324e67e66c4afb80e11067eb73e7c4aa96776515f63cf7cef2aa94
    HEAD_REF main                
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=include/syscalls-cpp
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME syscalls-cpp)

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
