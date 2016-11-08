include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyxml2-3.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/leethomason/tinyxml2/archive/3.0.0.zip"
    FILENAME "tinyxml2-3.0.0.zip"
    SHA512 3581e086e41ea01418fdf74e53b932c41cada9a45b73fb71c15424672182dc2a1e55110f030962ae44df6f5d9f060478c5b04373f886da843a78fcabae8b063c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyxml2/readme.md ${CURRENT_PACKAGES_DIR}/share/tinyxml2/copyright)
vcpkg_copy_pdbs()
