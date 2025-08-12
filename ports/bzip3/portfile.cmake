vcpkg_download_distfile(DISABLE_PTHREADS_BY_DEFAULT_PATCH
    URLS https://github.com/iczelia/bzip3/commit/557a3d75695699cb841008809142aa865b278b2c.diff?full_index=1
    FILENAME bzip3-disable-pthread-by-default-557a3d75695699cb841008809142aa865b278b2c.diff
    SHA512 c706b8c814b51eb48e9070c3ef6ab27600fed310f3c109d39da1329c79d0b9a4573ad30f662a6177490fdccaf3c1c74701c694780a0b382f159791563704fed7
)

vcpkg_download_distfile(FIX_DLLS_PATCH
    URLS https://github.com/iczelia/bzip3/commit/dca13c82311e60cc47f01623d6281119024b5b44.diff?full_index=1
    FILENAME bzip3-fix-dlls-dca13c82311e60cc47f01623d6281119024b5b44.diff
    SHA512 343a4a9db7c419d8c7d24e56cd800af471d8d0185d1ac475a79de820aff458f29de78ef7cb1c5af590f972917665c0ead8576473c22633f49b31f186f5905a97
)

vcpkg_download_distfile(ADD_FIND_DEPENDENCY_CALL_PATCH
    URLS https://github.com/iczelia/bzip3/commit/4c7224979ba5c06fdecb981c61e5316cf2e02c63.diff?full_index=1
    FILENAME bzip3-add-find-dependency-call-4c7224979ba5c06fdecb981c61e5316cf2e02c63.diff
    SHA512 f86e2e968ab33bbe9a7c3a9451dea65481cdd5040e84aec3765384ef1186439996ccb3c4ff8757f48bafac51c3ed646c713ebafac09ca65941ddffe73b541104
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iczelia/bzip3
    REF ${VERSION}
    SHA512 4010194b5cadf94356a9be8f9b87b287c8d098b02377ad106038f469a90812abef7ae05b5ca87896b71f0e0ad304b8971b75e45136f0d9fabf83d0cc21cf9202
    HEAD_REF master
    PATCHES
        "${DISABLE_PTHREADS_BY_DEFAULT_PATCH}"
        "${FIX_DLLS_PATCH}"
        "${ADD_FIND_DEPENDENCY_CALL_PATCH}"
        disable-man.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools    BZIP3_BUILD_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bzip3)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
