vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF "v${VERSION}"
    SHA512 29abb465a888aa4284795e293624598c09e0ba690bb430adb7a2122d82985daa1cfcfd594120f5657fc70349f8480e63554d72bff1b23f9dca86bcdbb930d953
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
