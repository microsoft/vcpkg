vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maharmstone/tdscpp
    REF "${VERSION}"
    HEAD_REF master
    SHA512 62cab90e17394a5f1c4058bc3a606c1f9542fbad4a749032964ae76dfbcf903f7ff1b20a459c2b3d784c4abb31b5abe7e582b30eaebd83ac9887629221f4a694
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
