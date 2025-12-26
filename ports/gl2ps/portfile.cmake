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
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/README.txt"
        "${SOURCE_PATH}/COPYING.LGPL"
        "${SOURCE_PATH}/COPYING.GL2PS"
)
