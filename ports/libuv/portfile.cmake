include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuv/libuv
    REF v1.21.0
    SHA512 ab6b52f8bee1900953d9136e4d281f81ba9f14287760f7bfc8633289699cb9eeaab15d9146ed05b164631fcb3c2b5abcee8c10499d080a82a411bb1f02564c48
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
