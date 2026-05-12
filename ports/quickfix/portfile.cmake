vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quickfix/quickfix
    REF v${VERSION}
    SHA512 fbd45940334ea4d9f6e1f4164b0dfc0f509bd75689aa39b80ab5303b9be4f2123428e71d967f46bc5bc47ae1a521180af5ba7b619daff5f835c3dfb6dec03d50
    HEAD_REF master
    PATCHES
        00001-fix-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QUICKFIX_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DQUICKFIX_SHARED_LIBS=${QUICKFIX_SHARED_LIBS}
        -DQUICKFIX_EXAMPLES=OFF
        -DQUICKFIX_TESTS=OFF
        -DHAVE_MYSQL=OFF
        -DHAVE_ODBC=OFF
        -DHAVE_POSTGRESQL=OFF
        -DHAVE_PYTHON3=OFF
        -DHAVE_SSL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/quickfix)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
