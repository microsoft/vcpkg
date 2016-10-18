include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/freeglut/freeglut/3.0.0/freeglut-3.0.0.tar.gz"
    FILENAME "freeglut-3.0.0.tar.gz"
    SHA512 9c45d5b203b26a7ff92331b3e080a48e806c92fbbe7c65d9262dd18c39cd6efdad8a795a80f499a2d23df84b4909dbd7c1bab20d7dd3555d3d88782ce9dd15b0
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freeglut-3.0.0
    OPTIONS
        -DFREEGLUT_BUILD_STATIC_LIBS=OFF
        -DFREEGLUT_BUILD_DEMOS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/freeglut-3.0.0/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freeglut)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freeglut/COPYING ${CURRENT_PACKAGES_DIR}/share/freeglut/copyright)
