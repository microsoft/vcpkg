# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unterumarmung/fixed_string
    REF v0.1.0
    SHA512 759c228e3bc4bc06d58b59bc19756ceb27a6f6104cb0c58288bf3156ca0958e6099741870fa09ba88a5572d17988529992cc5198faab30847118665e626c2ea4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFIXED_STRING_OPT_BUILD_EXAMPLES=OFF
        -DFIXED_STRING_OPT_BUILD_TESTS=OFF
        -DFIXED_STRING_OPT_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fixed_string TARGET_PATH share/fixed_string)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
