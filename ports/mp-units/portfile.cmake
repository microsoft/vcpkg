if(VCPKG_TARGET_IS_LINUX)
    message("Note: `mp-units` requires Clang16+ or GCC11+")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF "v${VERSION}"
    SHA512 7968b215c6b27a7a988ce41235139a57be6bb849db6d6ea0df46b0a40d279d4be4c53646c5a4bf695fb9e70ff4967d3fd443fec8ee40c4ab7f0c90d8695632c3
    PATCHES
      config.patch
)

set(USE_STD_FORMAT TRUE)
if ("use-libfmt" IN_LIST FEATURES)
    set(USE_STD_FORMAT FALSE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
    -DMP_UNITS_API_STD_FORMAT=${USE_STD_FORMAT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Handle copyright/readme/package files
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only
