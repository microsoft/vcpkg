vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF 8241475c5e5bd044738bf58adbe55afa366e81f2
    SHA512 c7552dbc154f62cf83a52adfa30ff5bd8e1af0c99aa40a122175d87b08d578c847076416712d293102e8554097807574c2d5d9f7bdc2dfce024556e9d65c3890
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
