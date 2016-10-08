include(vcpkg_common_functions)
SET(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/Sery-1.0")
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Ninetainedo/Sery/archive/v1.0.zip"
    FILENAME "sery-1.0.0.zip"
    SHA512 15ef97bf094e8931049d8dd667a778e23847555f0f8d5b949b250e26edcc2541744fac5c34d935880d070546777fa787b1baf018d8ca2240fcd18a820aded04f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Removes unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sery)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sery/LICENSE ${CURRENT_PACKAGES_DIR}/share/sery/copyright)

# Moves cmake files where appropriate
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/sery/cmake)
