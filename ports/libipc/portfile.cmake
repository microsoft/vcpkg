vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mutouyun/cpp-ipc
    REF 8dadafab9a835fa34edda07ee1401d69ef53e097
    SHA512 96d69c790119f690837e524b69f4e5964052013fd655e8e2e92c6d3255399615b89b8f5b1d8e86078b7ea35996abc33408d51208eef61feaad90ded53f2ed0f1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBIPC_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
    OPTIONS
        -DLIBIPC_BUILD_SHARED_LIBS:BOOL=${LIBIPC_BUILD_SHARED_LIBS}
        -DUSE_STATIC_CRT:BOOL=${USE_STATIC_CRT}
        -DLIBIPC_BUILD_TESTS:BOOL=OFF
        -DLIBIPC_BUILD_DEMOS:BOOL=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/cpp-ipc)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cpp-ipc)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/cpp-ipc)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cpp-ipc)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/libipc/export.h LIBIPC_EXPORT_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "#elif defined(LIBIPC_LIBRARY_SHARED_USING__)" "#elif 1" LIBIPC_EXPORT_H "${LIBIPC_EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libipc/export.h "${LIBIPC_EXPORT_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
