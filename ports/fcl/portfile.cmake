if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF a3fbc9fe4f619d7bb1117dc137daa497d2de454b # unrelased (Mar 13, 2025)
    SHA512 d04db55768d27cd191cf72ee3cc7ffeb5164c0d5db8bd38eb8ed523846e205340947f0b64473d567db0bc56bf8e8da330dc6e5e2929066e6d0f512fd5a7cbd92
    HEAD_REF master
    PATCHES
        0001-fix-cxx-standard.patch
        0002-fix-eigen3.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" FCL_STATIC_LIBRARY)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(FCL_USE_X64_SSE ON)
else()
    set(FCL_USE_X64_SSE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_Eigen3=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_ccd=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_octomap=1
        -DFCL_STATIC_LIBRARY=${FCL_STATIC_LIBRARY}
        -DFCL_USE_X64_SSE=${FCL_USE_X64_SSE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fcl)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
