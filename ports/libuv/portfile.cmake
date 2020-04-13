vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF f868c9ab0c307525a16fff99fd21e32a6ebc3837 # v1.34.2
    SHA512 1a64b34dc488a6fc6f563246e6e79f11d64f16cf9f2f1dab3eb38af9e5cf6ff513f67168bef95f72d260291259adda9567f982e0158bcfdacce15f5d23431ecf
    HEAD_REF v1.x
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DUV_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-libuv TARGET_PATH share/unofficial-libuv)
vcpkg_copy_pdbs()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/unofficial-libuv-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/unofficial-libuv/unofficial-libuv-config.cmake
    @ONLY
)

file(READ ${CURRENT_PACKAGES_DIR}/include/uv.h UV_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(USING_UV_SHARED)" "1" UV_H "${UV_H}")
else()
    string(REPLACE "defined(USING_UV_SHARED)" "0" UV_H "${UV_H}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/uv.h "${UV_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

