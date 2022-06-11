vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vancegroup/freealut
    REF fc814e316c2bfa6e05b723b8cc9cb276da141aae
    SHA512 046990cc13822ca6eea0b8e412aa95a994b881429e0b15cefee379f08bd9636d4a4598292a8d46b30c3cd06814bfaeae3298e8ef4087a46eede344f3880e9fed
    HEAD_REF master
    PATCHES
        cmake_builds.patch
        unix_headers.patch 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
 )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/freealut-config")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/freealut-config")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/freealut-config")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/freealut-config")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
