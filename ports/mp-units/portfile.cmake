if(VCPKG_TARGET_IS_LINUX)
    message("Note: `mp-units` requires Clang16+ or GCC11+")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF "v${VERSION}"
    SHA512 5e01cc4ee6cbbaf81f02c9268dfa8f0ca348925a85f84704f06405874edb478437837900e6fbe882aba9e9040235310d82b6420fd81b39eb1cc8d38570e48613
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
