include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF v3.3
    SHA512 391be695114759c9eef56dbb20d039a20f88bc9b852285e950788ce5118dcf69f29c5497b62f5b18b6f777760b0bc17534d71eda40628046acfc861c7f7c2356
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/no-absolute-paths-in-install.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLAZE_SMP_THREADS=C++11
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
