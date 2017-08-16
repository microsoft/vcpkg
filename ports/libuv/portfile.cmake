include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.14.0
    SHA512 a838f2e97250a78861b72458d9278935d9e8151d69de21de19499dfe9d7304d65ce578c007356b75cd4ce2c17735292d93cdb2fcc206d4e2430ee3f9a2fc7222
    HEAD_REF v1.x)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DUV_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/uv.h UV_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(USING_UV_SHARED)" "1" UV_H "${UV_H}")
else()
    string(REPLACE "defined(USING_UV_SHARED)" "0" UV_H "${UV_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/uv.h "${UV_H}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libuv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libuv/LICENSE ${CURRENT_PACKAGES_DIR}/share/libuv/copyright)
