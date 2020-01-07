vcpkg_download_distfile(ARCHIVE
    URLS "https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2"
    FILENAME "libftdi1-1.4.tar.bz2"
    SHA512 dbab74f7bc35ca835b9c6dd5b70a64816948d65da1f73a9ece37a0f0f630bd0df1a676543acc517b02a718bc34ba4f7a30cbc48b6eed1c154c917f8ef0a358fc
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF 1.4
    PATCHES
        cmake-fix.patch
        win32.patch
        fix-libusb-path.patch
        fix-ftdi1-path.patch
        fix-cmake-path.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOCUMENTATION=OFF
        -DEXAMPLES=OFF
        -DPYTHON_BINDINGS=OFF
        -DLINK_PYTHON_LIBRARY=OFF

        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Confuse=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libintl=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonLibs=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libftdi1 TARGET_PATH share/libftdi1)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi1)
