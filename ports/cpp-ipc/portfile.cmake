vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mutouyun/cpp-ipc
    REF v${VERSION}
    SHA512 114534b28654b9085b3d757fbb1d03aec6f6eb6b34312168f5e72f03e75f57299714dba20f345be5ecc940b38eb7d956a42a41ae82f12d722a27075ac27e31d9
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBIPC_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LIBIPC_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBIPC_BUILD_SHARED_LIBS:BOOL=${LIBIPC_BUILD_SHARED_LIBS}
        -DLIBIPC_USE_STATIC_CRT:BOOL=${LIBIPC_USE_STATIC_CRT}
        -DLIBIPC_BUILD_TESTS:BOOL=OFF
        -DLIBIPC_BUILD_DEMOS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/cpp-ipc")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpp-ipc)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/cpp-ipc")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/cpp-ipc)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libipc/export.h" "#elif defined(LIBIPC_LIBRARY_SHARED_USING__)" "#elif 1")
endif()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
