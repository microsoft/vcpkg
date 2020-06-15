vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
# TODO: Fix .dlls not producing .lib files

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlx/tlx
    REF d59c325fb31812047e61aba3d75cc037f92c2b3d
    SHA512 5bf79b35cdf47f2eeca8d38a5cce045ce99da21146303861e66d9926aa3fd48ab2eb07867232245339cd270b118ae9ed51154b6793b54b0bc876bd24c5152ba1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVERBOSE=1
        -DTLX_BUILD_TESTS=off
        -DTLX_USE_GCOV=off
        -DTLX_TRY_COMPILE_HEADERS=off
        -DTLX_MORE_TESTS=off
        -DTLX_BUILD_STATIC_LIBS=${BUILD_STATIC}
        -DTLX_BUILD_SHARED_LIBS=${BUILD_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
