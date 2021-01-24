vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/libkeyfinder
    REF 99c59aa4eb68071cb5ac8ce0944247a88d417143
    SHA512 1a79b41a4314dcca9356a50f906710e2fd5697e653469ef06970a1e3fc696460bb35544754f5f80bcd55c5cbc8cc01d800175fb2d6d7dc7b21d4cccfae568fa2
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${LIBKEYFINDER_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KeyFinder TARGET_PATH share/KeyFinder)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libkeyfinder RENAME copyright)
