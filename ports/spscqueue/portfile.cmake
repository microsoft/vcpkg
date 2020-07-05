vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/SPSCQueue
    REF v1.0
    SHA512 8776b49070d549b1df155b0a1ad876a4145d75e004269b3573e8f9963329ad05350d323d87bae229c793cbaf1f2421e35fa7e923e68cc4dcd9cfb6698e8cd80e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SPSCQueue)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
