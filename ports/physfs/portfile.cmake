vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO icculus/physfs
    REF ccffd00e1202a4fbd655f7c84171eee6182d9a53
    SHA512 bb091329dbfe2830c3b7b384ba1c5b69fd48be7780ed00dca7507d51b5f7321c0a9d939127cf425992330e07914881fb4921c70f80a635bf85e29b5783d99a80
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PHYSFS_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PHYSFS_SHARED)

set(generator_param "")
if(VCPKG_TARGET_IS_UWP)
    set(generator_param WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${generator_param}
    OPTIONS
        -DPHYSFS_BUILD_STATIC=${PHYSFS_STATIC}
        -DPHYSFS_BUILD_SHARED=${PHYSFS_SHARED}
        -DPHYSFS_BUILD_TEST=OFF
        -DPHYSFS_BUILD_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PhysFS)
endif()
vcpkg_fixup_pkgconfig()

if(PHYSFS_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/physfs.h" "defined(PHYSFS_STATIC)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/physfs.h" "dllexport" "dllimport")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
