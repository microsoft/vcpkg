vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF "v${VERSION}"
    SHA512 6369c886629955c6457911b98a702c29bacce58e9049e1da700055a3f8b1981cce4f545c1d09550ec1c57f8805f7fc1f0198118950a14b2a7b797dd437ed72df
    PATCHES
      config.patch
)

set(USE_LIBFMT OFF)
if ("use-libfmt" IN_LIST FEATURES)
    set(USE_LIBFMT ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
      -DUNITS_USE_LIBFMT=${USE_LIBFMT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Handle copyright/readme/package files
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only
