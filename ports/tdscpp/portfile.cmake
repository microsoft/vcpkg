vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maharmstone/tdscpp
    REF "${VERSION}"
    HEAD_REF master
    SHA512 96ccfe86ecbe34fa7c55115d33ceb277c065f3ffef8600e1cf5df5daf458fedf35e994d3d335b5724436bf283622d32252616d4e9336fcf0123af5edb3f32bf1
)

set(BUILD_tdscpp_ssl OFF)

if("ssl" IN_LIST FEATURES)
    set(BUILD_tdscpp_ssl ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DWITH_OPENSSL=${BUILD_tdscpp_ssl}
        -DBUILD_SAMPLE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tdscpp)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
