vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ogdf/ogdf
    REF 214105da97863e1d0a066157e5cc573b65b433a9
    SHA512 8ab9f266fef224ce600cec418d5de56761714fbaa2d509ba89d55700c1d27d02a5fc93fab8eb8e10325a42c7d2fa8e251e2a18ece9a9565e215bf39672bff92d
    HEAD_REF master
    PATCHES 
        add-include-chrono.patch # https://github.com/ogdf/ogdf/pull/254
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOIN_INSTALL_LIBRARY_DIR:STRING=lib
        -DCOIN_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
        -DOGDF_INSTALL_LIBRARY_DIR:STRING=lib
        -DOGDF_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OGDF)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/minisat/doc" "${CURRENT_PACKAGES_DIR}/include/ogdf/lib/minisat/doc")
