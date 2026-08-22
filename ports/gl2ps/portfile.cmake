vcpkg_download_distfile(ARCHIVE
    URLS "https://geuz.org/gl2ps/src/gl2ps-${VERSION}.tgz"
    FILENAME "gl2ps-${VERSION}.tgz"
    SHA512 46652e1b3825ace61dbd77c4b0bf451e7671c248eb18bbd3369e2fac00056ea4cd5d2578561984313c239e3b02f78b9d9a76d963c935af65a13bc2abfc538620
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        separate-static-dynamic-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
        -DVCPKG_LOCK_FIND_PACKAGE_GLUT=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_LATEX=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_OpenGL=ON
)
vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gl2ps.h" "defined\(GL2PSDLL\)" "(1)")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gl2ps.h" "defined(HAVE_ZLIB)" "(1)")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gl2ps.h" "defined(HAVE_LIBPNG)" "(1)")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/README.txt"
        "${SOURCE_PATH}/COPYING.LGPL"
        "${SOURCE_PATH}/COPYING.GL2PS"
)
