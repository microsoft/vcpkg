vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luvit/luv
    REF 1f255a7d87cef4a7eb10bd13bbd1e213980e8da2  #v1.44.2
    SHA512 e9ee9ee6ca8f810c375f3310a119b518da8d15f6e3093aaa6069217f4e3d29a45426cc5e2233b6a8d90876867d9097c938a5b961fb6e46479c62145297f5bb82
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
