include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/Ninetainedo/Sery/archive/v1.0.zip"
    FILENAME "sery-1.0.0.zip"
    SHA512 15ef97bf094e8931049d8dd667a778e23847555f0f8d5b949b250e26edcc2541744fac5c34d935880d070546777fa787b1baf018d8ca2240fcd18a820aded04f
)
vcpkg_extract_source_archive(${ARCHIVE})

SET(SERY_ROOT_DIR "${CURRENT_BUILDTREES_DIR}/src/Sery-1.0")

vcpkg_configure_cmake(
    SOURCE_PATH ${SERY_ROOT_DIR}
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
file(COPY ${SERY_ROOT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sery)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sery/LICENSE ${CURRENT_PACKAGES_DIR}/share/sery/copyright)

# Moves cmake files where appropriate
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/sery/cmake)
