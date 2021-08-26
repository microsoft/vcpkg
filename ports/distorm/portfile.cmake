vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdabah/distorm
    REF v3.4.1
    SHA512 0e9f8b62bc190ef7d516f1902b6003adef9c7d5d4a5f985fb0bdfc5d4838b2805e2b8836b02d5eccdb3401e814417de615dec675aed9e606c93122ca8a0d2083
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/distorm RENAME copyright)
