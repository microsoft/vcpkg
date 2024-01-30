vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanosvg
    REF 9da543e8329fdd81b64eb48742d8ccb09377aed1
    SHA512 9c91df8ac67dbd1a920d5287c6d267c6163d28b6ff75899452ca49097bbe881655799d4b003e667422062d0b7e6aa6bd6bf4c3d941d0301cbc23c6459d8d25d7
    HEAD_REF master
    PATCHES fltk.patch # from fltk/nanosvg
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NanoSVG PACKAGE_NAME NanoSVG)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
