include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://openal-soft.org/openal-releases/openal-soft-1.17.2.tar.bz2"
    FILENAME "openal-soft-1.17.2.tar.bz2"
    MD5 1764e0d8fec499589b47ebc724e0913d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openal-soft-1.17.2
    OPTIONS
        -DALSOFT_UTILS=OFF
        -DALSOFT_NO_CONFIG_UTIL=ON
        -DALSOFT_EXAMPLES=OFF
        -DALSOFT_TESTS=OFF
        -DALSOFT_CONFIG=OFF
        -DALSOFT_HRTF_DEFS=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/openal-soft-1.17.2/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/openal-soft)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openal-soft/COPYING ${CURRENT_PACKAGES_DIR}/share/openal-soft/copyright)
vcpkg_copy_pdbs()

