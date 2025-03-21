vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF "v${VERSION}"
    SHA512 083b92079bf324fb9e50b3d6291ee3654b8e4e2926c292c9dc092b1c4ce336ce4d4bbea7e14d52291340c692887b8ab92d1f9f3d50aed6092b5465242572bfdc
    HEAD_REF dev
    PATCHES
        fix_findpkg.patch
)
vcpkg_find_acquire_program(GIT)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS
        ${BACKEND_OPTION}
        -Dsaucer_prefer_remote=OFF
        -Dsaucer_remote_webview2=OFF
        -Dsaucer_serializer=Rflpp
        -Dsaucer_tests=OFF
        -Dsaucer_examples=OFF
        "-DGIT_EXECUTABLE=${GIT}"
    MAYBE_UNUSED_VARIABLES
        saucer_remote_webview2
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/reflectcpp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/ereignis")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/flagpp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/lockpp")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
