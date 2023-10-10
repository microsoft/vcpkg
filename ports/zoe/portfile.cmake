vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF 62e5dedcfd1fc2e0d22a91f1ebd84bb4e3a319e2
    SHA512 e7f5bb4a879a80efe10e5cf922751d01c6706f3b1d6c5280cdd14353be6fda31e2c7572051f610120ffd33cb775c7995d2863e5b4b4292f16f2cc721277bf8c2
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
