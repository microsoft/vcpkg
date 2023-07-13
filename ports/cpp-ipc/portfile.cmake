vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mutouyun/cpp-ipc
    REF f2f1af8f8e7877a28deb2eacdc379a22a99e4c82 #v1.2.0
    SHA512 e01fe5e2612141af64a9c44773a49c566b89ecf0a77164c6eb0a6d68bd7ff5830843ce42df5d53a863882b582a8d6a2e9f69026f244d8d1d96e83f0f4c9e8972
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
