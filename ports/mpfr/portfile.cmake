include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpfr-3.1.6)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-3.1.6/mpfr-3.1.6.tar.xz"
    FILENAME "mpfr-3.1.6.tar.xz"
    SHA512 746ee74d5026f267f74ab352d850ed30ff627d530aa840c71b24793e44875f8503946bd7399905dea2b2dd5744326254d7889337fe94cfe58d03c4066e9d8054
)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/gmp_printf.c DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpfr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mpfr/COPYING ${CURRENT_PACKAGES_DIR}/share/mpfr/copyright)
