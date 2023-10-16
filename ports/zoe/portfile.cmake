vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF 28bf5d06629e7e5102a704a5a3589e070e4f158d
    SHA512 448f6a6d2b698ad7eea089303f3f5cbcb067972ab950cae49558aec995031551c9dfc5e23f6ff4ee05d0ec508f773960d13897f62762f2e5f43bdc34b9cca7d6
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ZOE_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOE_BUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
        -DZOE_USE_STATIC_CRT:BOOL=${ZOE_USE_STATIC_CRT}
        -DZOE_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/zoe")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zoe)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/zoe")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/zoe)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()
