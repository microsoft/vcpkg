if(VCPKG_TARGET_IS_LINUX)
    message("Note: `mp-units` requires Clang16+ or GCC11+")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF "v${VERSION}"
    SHA512 994922a391ed5c1d0e023545beeb0bbeb8ec067be408f715d553e509d9106cdb5b27cfbaa69f0ca1a27cdf9532edacaff7d2cabaafd54b1713f9c8add93bc389
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
