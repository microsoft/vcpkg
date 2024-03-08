vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luvit/luv
    REF "${VERSION}"
    SHA512 605caf39b88938832849d9ac982001a3a720ce0b9044462e2f7038c2ba694cc9c5ad73622f8b6623e9afa821edd7361438e913f1a37908a965a6c118fc7b835d
    HEAD_REF master
    PATCHES fix-find-libuv.patch
            fix-find-luajit.patch
            fix-find-lua-compat53.patch
            fix-msvc-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_SHARED_LIBUV=ON
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DLUA_BUILD_TYPE=System
        -DWITH_LUA_ENGINE=LuaJIT
        -DUSE_LUAJIT=ON
        -DBUILD_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
