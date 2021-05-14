vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF 25f4b8b8a3c0f934158cd37a37b0525d75ca488e # v1.39.0
    SHA512 749f89aaaee26237ace84f0ff6ff2e703ba8c2ff7ec81f1c90844876dd865fe925ef0028fdb2fef92c7aa8eca5f66aefe43effad7d7def4240d3f57b848acbe1
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

