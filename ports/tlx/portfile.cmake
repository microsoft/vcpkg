vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
# TODO: Fix .dlls not producing .lib files

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlx/tlx
    REF 903b9b35df8731496a90d8d74f8bedbad2517d9b
    SHA512 17087973f2f4751538c589e9f80d2b5ea872d2e7d90659769ae3350d441bda0b64aec9a4150d01a7cf5323ce327ebd104cdca7b4a3bc4eebdf574e71e013ba6e
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
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake/")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/tlx")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
