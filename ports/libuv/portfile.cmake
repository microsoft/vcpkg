include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.24.0
    SHA512 b75dac19e99497b059b9b8ce646266c4fa10f1259f5fd74554f7f614f7b70f4b62b9c756316d9a3eed6cf6b9d61f5acde9f6eedb88d30431f6a5c87169487ec6
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
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/uv.h "${UV_H}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libuv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libuv/LICENSE ${CURRENT_PACKAGES_DIR}/share/libuv/copyright)
