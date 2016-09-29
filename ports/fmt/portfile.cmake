include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fmt-3.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/fmtlib/fmt/archive/3.0.0.tar.gz"
    FILENAME "fmt-3.0.0.tar.gz"
    SHA512 20c9b1ffe8b46cb5d22015122fc698a75ad854709d3de1a1316b6040d86f54bada4e6d7263f2f1fd94cb13ac37ee9447c162c6aec3f3af650455e8a8a9804871
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_build_cmake()

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmt RENAME copyright)
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
