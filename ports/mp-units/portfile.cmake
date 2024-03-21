if(VCPKG_TARGET_IS_LINUX)
    message("Note: `mp-units` requires Clang16+ or GCC11+")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF "v${VERSION}"
    SHA512 d23589ba6e5e18e3477a9bab9fe25cffed5e8777862b4811e4335e294f86d129a48c7e001d57cec0739ddd1f0a936e42d06f2b4782b1bd8b8bb15f86f8d32d53
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
      -DMP_UNITS_USE_LIBFMT=${USE_LIBFMT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Handle copyright/readme/package files
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only
