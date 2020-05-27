vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rafat/wavelib
    REF cef10c11334007e958daa977f40af1eca7ffb5b8
    SHA512 20403990fe151d623ef10970056db7dccc659c667f5eba999ab8659849e7cd5c8c8474a7892dae5e66b4a7ef372ec69332f2f8dd2ebf75ee6f35be408f0e48ea
    HEAD_REF master
    PATCHES
        fix-cmake-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_UT=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
