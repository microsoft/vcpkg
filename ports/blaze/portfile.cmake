include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF v3.4
    SHA512 bdfc04aa07263f508079f8b1613dc7afe61ec3e3137b4f7b2900331d32d8358341c6b6cc7afd6e893246b5497f3289e1d2ad0f3af37b443eab1122ff479f065c
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/no-absolute-paths-in-install.patch"
        "${CMAKE_CURRENT_LIST_DIR}/no-generate-to-source-dir.patch"
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
