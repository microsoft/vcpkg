# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF master
    SHA512 429215a961cfcfe8fcb49ee48970dd10dccad09a5c80db2eea2413120a51a2529c9a650584a079756c3b463d53f1fcdec46fdc158ffbc680592896867f60d3ea
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENXLSX_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenXLSX)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(COPY "${SOURCE_PATH}/OpenXLSX/external" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/OpenXLSX/headers/XLException.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")


vcpkg_copy_pdbs()


# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
