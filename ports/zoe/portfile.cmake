vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF 00788994c84fd5351a2f0696fc83d341c3c2d161
    SHA512 8b5e83a0f4d47422cf3fd6b8f27a05b92ca941ecf1f6abe35310f3ffe7fed5eb4d951c2a946ba5ad534921ba62cdcf4eafcfabf69720b5dbb10214b9f342bec2
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBRARY_LINKAGE_HAS_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ZOE_USE_STATIC_CRT)

if(${LIBRARY_LINKAGE_HAS_STATIC})
	set(ZOE_BUILD_SHARED_LIBS OFF)
else()
	set(ZOE_BUILD_SHARED_LIBS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOE_BUILD_SHARED_LIBS:BOOL=${ZOE_BUILD_SHARED_LIBS}
        -DZOE_USE_STATIC_CRT:BOOL=${ZOE_USE_STATIC_CRT}
        -DZOE_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/zoe")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zoe)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/libGet")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/zoe)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()
