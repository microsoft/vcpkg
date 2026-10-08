vcpkg_download_distfile(ARCHIVE
    URLS "https://geuz.org/gl2ps/src/gl2ps-${VERSION}.tgz"
    FILENAME "gl2ps-${VERSION}.tgz"
    SHA512 1dae715f7e157f686a3a47865711d59c1ae7a0fb736d3ec065f8a08e6adea5418d59b81d41295fad58762b20da8aed22cdefddcc54ac0a54c697f32f101ea10c
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        static-no-dll-exports.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGL2PS_DOC=share/doc
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
