include(vcpkg_common_functions)
set(GSL_VERSION 2.4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gsl-${GSL_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz"
    FILENAME "gsl-${GSL_VERSION}.tar.gz"
    SHA512 12442b023dd959e8b22a9c486646b5cedec7fdba0daf2604cda365cf96d10d99aefdec2b42e59c536cc071da1525373454e5ed6f4b15293b305ca9b1dc6db130
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-configure.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-add-fp-control.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsl/COPYING ${CURRENT_PACKAGES_DIR}/share/gsl/copyright)

vcpkg_copy_pdbs()
