vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF "v${VERSION}"
    SHA512 6b5090c7754cac99d410ae59e207a44cd58db7fc9ee59412181c13449c5aed7e1cb61b1ec0703809084b406e01bbb821ecafa5caee4c2704ef72f07d2979a7e0
    HEAD_REF dev
    PATCHES
        fix_findpkg.patch
        fix-build-error-with-fmt11.patch
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
