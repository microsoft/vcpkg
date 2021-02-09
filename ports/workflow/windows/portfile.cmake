vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/workflow
    REF eb0ef062cb4be64f3a152c740ed3d32e468c13fe
    SHA512 0dafe5637c78bfa8d415ef54d9ac91f6a6f525a5876ec54c321a533d05b010c1f94829107808348bbf2ffe58914547930abf2fc4b0b07c2990a55c44bb9fd2e3
    HEAD_REF windows
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

vcpkg_copy_pdbs()
