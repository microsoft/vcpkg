include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.20.0
    SHA512 382309cb6e54765b956b03357cb754f49d93505ba0e0122a77f33efca07d7b87966c993a5fd9f9503edd1bcd0f49ca42bd9cd9264cce94c847aebca77d237ba0
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
