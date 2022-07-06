vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF e8b7eb6908a847ffbe6ab2eec7428e43a0aa53a2  #v1.44.1
    SHA512 c8918fe3cdfcfec7c7da4af8286b5fd28805f41a40a283a22ff578631835539d9f52b46310f1ac0a464a570f9664d6793bb6c63541f01a4f379b3ad2f7c56aea
    HEAD_REF v1.x
    PATCHES fix-build-type.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBUV_BUILD_TESTS=OFF
        -DQEMU=OFF
        -DASAN=OFF
        -DTSAN=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libuv)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uv.h" "defined(USING_UV_SHARED)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uv.h" "defined(USING_UV_SHARED)" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

