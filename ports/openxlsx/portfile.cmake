# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF "v${VERSION}"
    SHA512 52205b394383d45c0fb16599ab96453d8a5b9b5cd596096848cc888f47565b2713d9edded06b2ecd7b67736622badf136e4b1becc57bfa5bbdcb1e063a347084
    HEAD_REF master
    PATCHES
        compilation_fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPENXLSX_BUILD_TESTS=OFF
        -OPENXLSX_CREATE_DOCS=OFF
        -OPENXLSX_BUILD_SAMPLES=OFF
        -DOPENXLSX_BUILD_BENCHMARKS=OFF
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
