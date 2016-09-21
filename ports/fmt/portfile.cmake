include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE_FILE
    URL "https://github.com/fmtlib/fmt/archive/3.0.0.tar.gz"
    FILENAME "fmt-3.0.0.tar.gz"
    MD5 deeac02aa6d00d6d04502087fdf88b6f
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fmt-3.0.0
    OPTIONS
        -DFMT_TEST=OFF
)

vcpkg_build_cmake()

vcpkg_install_cmake()
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/fmt-3.0.0/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmt RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/fmt/format.cc)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/fmt/ostream.cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/fmt/fmt-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-config-version.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/fmt/fmt-config.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/fmt/fmt-targets-release.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/fmt/fmt-targets.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/fmt/fmt-targets.cmake ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

vcpkg_copy_pdbs()
