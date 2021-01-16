vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/libkeyfinder
    REF 1c55a91dbf58b555f6f74ea425c75a98e77e4296
    SHA512 ac98374d1a90d065183f1ed691a569f1af9fe1b000ddb0d52f56d88fac716cf5302df1490f009aaaa4b269c7563a5ce38e04f9539ee6d76727b971cb118f56d5
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
