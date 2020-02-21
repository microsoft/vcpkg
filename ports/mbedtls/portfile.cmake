include(vcpkg_common_functions)

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF mbedtls-2.16.3
    SHA512 3d798f7de9c33325585d5d7c8608cc16acdcf42c246d283b2fb8a29f5e419f2899342965ff297432ef2ab20c91eaee28d6ca53349f5a68b0a4fd29d6905fc64c
    HEAD_REF master
    PATCHES
        enable-pthreads4w.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pthreads ENABLE_PTHREADS4W
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mbedtls RENAME copyright)

vcpkg_copy_pdbs()
