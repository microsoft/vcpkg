vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF e8b7eb6908a847ffbe6ab2eec7428e43a0aa53a2  #v1.44.1
    SHA512 c8918fe3cdfcfec7c7da4af8286b5fd28805f41a40a283a22ff578631835539d9f52b46310f1ac0a464a570f9664d6793bb6c63541f01a4f379b3ad2f7c56aea
    HEAD_REF v1.x
    PATCHES
        fix-ci-error.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DUV_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libuv CONFIG_PATH share/unofficial-libuv)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-libuv-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-libuv/unofficial-libuv-config.cmake"
    @ONLY
)

file(READ "${CURRENT_PACKAGES_DIR}/include/uv.h" UV_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(USING_UV_SHARED)" "1" UV_H "${UV_H}")
else()
    string(REPLACE "defined(USING_UV_SHARED)" "0" UV_H "${UV_H}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/uv.h" "${UV_H}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

