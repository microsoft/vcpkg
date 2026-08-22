vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
# TODO: Fix .dlls not producing .lib files

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlx/tlx
    REF "v${VERSION}"
    SHA512 62115a6741fd8f0c84ea514b4aaccb62a8ed8e74ef2ad1d2822719ea6b8e3543f3eb1cca4324b4b10cbab9c208f1f021f5a73b76a6f03ae2038f7edad9c922a0
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERBOSE=1
        -DTLX_BUILD_TESTS=off
        -DTLX_USE_GCOV=off
        -DTLX_TRY_COMPILE_HEADERS=off
        -DTLX_MORE_TESTS=off
        -DTLX_BUILD_STATIC_LIBS=${BUILD_STATIC}
        -DTLX_BUILD_SHARED_LIBS=${BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH "CMake/")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tlx")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
