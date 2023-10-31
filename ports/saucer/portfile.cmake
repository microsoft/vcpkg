vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF "v${VERSION}"
    SHA512 2517f9c17d434b921adb3395d1489d2f1951833fe3fd2ee41ec84b22e4be398a6009cb37a08f96edee3114e65acd0c979e12d300514fc0df6cf756429b1b03b4
    HEAD_REF dev
    PATCHES
        fix_findpkg.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS
        ${BACKEND_OPTION}
        -Dsaucer_prefer_remote=OFF
        -Dsaucer_remote_webview2=OFF
    MAYBE_UNUSED_VARIABLES
        saucer_remote_webview2
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
