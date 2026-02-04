vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maharmstone/tdscpp
    REF "${VERSION}"
    HEAD_REF master
    SHA512 6f7f36918e1047355dc948a803b786df2aacc006654d0604e7af627c8c7d28a5e2fdbd52b306811e0da5ccca044ce231606d9208a04d5358aac62b9e1f9b3139
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
