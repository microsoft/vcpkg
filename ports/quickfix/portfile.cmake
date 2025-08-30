vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quickfix/quickfix
    REF 4e89249a90f5c8a140ffdd6eeb5e5cbf7a8e224b # change to "v${VERSION}" when officially released on github
    SHA512 5128f2626428b5161f5be6e7aba86de56d14b2a0955f0c07d6fa6adbc0c76bfd919faff513a0c94eedf9bb110bf9b57eac5880e93dfc22138529234b62855b62
    HEAD_REF master
    PATCHES
        00001-fix-build.patch
        00002-quickfix-663.patch # remove when https://github.com/quickfix/quickfix/pull/663 gets merged
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
        -DHAVE_PYTHON=OFF
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
