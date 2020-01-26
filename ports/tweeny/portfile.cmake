
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/tweeny
    REF v3
    SHA512 41f2562a0e55b0fd2c219fab384bf46f70432abb47953b5ac768a29b2ea7b790c6aa56fd44c1fef583f6fa2011010d7dd7e637bcd2d8a9be5c9638a7f2ce7436
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()


vcpkg_fixup_cmake_targets(CONFIG_PATH "/lib/cmake/Tweeny/")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake/Tweeny)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tweeny RENAME copyright)
