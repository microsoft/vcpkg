include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpfr-4.0.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-4.0.1/mpfr-4.0.1.tar.xz"
    FILENAME "mpfr-4.0.1.tar.xz"
    SHA512 137ad68bc1e33a155edc1247fcdba27f999cf48ed526773136584090ddf2cfdfc9ea79fbf74ea1943b835b4b1ff29b05087114738c6ad3b485848540f30cac4f
)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/test_stdarg.c DESTINATION ${SOURCE_PATH})

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
