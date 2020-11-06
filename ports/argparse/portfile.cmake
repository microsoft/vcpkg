# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/argparse
    REF 473d550ea313ea315a820b3b1b426254ad17061a # v2.1
    SHA512 59408a95e2ddb8d2e0f35229d58545569489f03b1a156fa9b9e92bbf7d669656045c3cffd8f2d939e1d749999cbc9ade7946eb2da1552b5edf2e069e893bdbaf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DARGPARSE_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
