include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://www.sfml-dev.org/files/SFML-2.4.0-sources.zip"
    FILENAME "SFML-2.4.0.zip"
    MD5 c15e4169b8cfeb2ab8bbc004a90c159a
)
vcpkg_extract_source_archive(${ARCHIVE})

SET(SFML_ROOT_DIR "${CURRENT_BUILDTREES_DIR}/src/SFML-2.4.0")

vcpkg_configure_cmake(
    SOURCE_PATH ${SFML_ROOT_DIR}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_cmake()
vcpkg_install_cmake()

# Removes unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

# Handle copyright
file(COPY ${SFML_ROOT_DIR}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sfml/license.txt ${CURRENT_PACKAGES_DIR}/share/sfml/copyright)

# Moves cmake files where appropriate
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/sfml/cmake)
