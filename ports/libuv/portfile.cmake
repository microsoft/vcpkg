vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF "v${VERSION}"
    SHA512 8f26c14b016368a8e382539026e1fa3cf187a7cc8bd8b50498a9b26003e9da3e48a89f4d2032694e5f152cd4177386e259b85e8280cf814153ab58950d205014
    HEAD_REF v1.x
    PATCHES
        fix-build-type.patch
        ssize_t.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBUV_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBUV_BUILD_TESTS=OFF
        -DLIBUV_BUILD_BENCH=OFF
        -DLIBUV_BUILD_SHARED=${LIBUV_BUILD_SHARED}
        -DQEMU=OFF
        -DASAN=OFF
        -DTSAN=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libuv)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(GLOB libuv_pc_files
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc"
    )
    foreach(libuv_pc_file IN LISTS libuv_pc_files)
        vcpkg_replace_string("${libuv_pc_file}" "-l:libuv.a" "-llibuv")
    endforeach()
endif()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uv.h" "defined(USING_UV_SHARED)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uv.h" "defined(USING_UV_SHARED)" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE-extra"
    "${SOURCE_PATH}/include/uv/tree.h"
    "${SOURCE_PATH}/src/heap-inl.h"
    "${SOURCE_PATH}/src/idna.h"
    "${SOURCE_PATH}/src/inet.c"
)
