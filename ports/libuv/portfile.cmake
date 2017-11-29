include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.17.0
    SHA512 274615dd67808a7b7481184aa9c1650f7646ffe714c5304ea123e287eb09cad2a4c677ac06ae68b7d0e70071545954aa6a80414cd7e37c242a2533563094870c
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
