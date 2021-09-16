vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mutouyun/cpp-ipc
    REF df3cf1b4c42143e6675c6fb0f33f85a48b7c7701 #v1.0.0
    SHA512 de319d48ac396f567b2f5faae87a264b9ebfbaf0559a3e00de61facd6a3f2de1739e064c6e037ad694111ed211c0fb9ea6ec2db0259c100e2bafe553c15ed2f6
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