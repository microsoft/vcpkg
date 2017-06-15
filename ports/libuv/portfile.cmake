include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.12.0
    SHA512 879359747e8319b6e951157f9406176c53ee24833ab9ea3e6ad2b9cf25368fd8f166fa2074b89bdb75e2a6a77757d91a079c4ef86b92330a8ea11519cd1e3018
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
