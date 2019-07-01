include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF 54e9619bc2b084ee50e986ac3308160d663481c4
    SHA512 11bfa3fdeeda6766769a34d2248ca32b6b13ecb32b412c068aa1c7aa3495d55b3f7a82a93621965904f9813c3fd0f128a84f796ae5731d2ff15b85935a0e1261
    HEAD_REF fcl-0.5
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_fix_package_detection.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-fix_dependencies.patch)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(FCL_STATIC_LIBRARY ON)
else()
    set(FCL_STATIC_LIBRARY OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFCL_STATIC_LIBRARY=${FCL_STATIC_LIBRARY}
        -DFCL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
  vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fcl)
endif()


file(READ ${CURRENT_PACKAGES_DIR}/share/fcl/fclConfig.cmake FCL_CONFIG)
string(REPLACE "unset(_expectedTargets)"
               "unset(_expectedTargets)\n\nfind_package(octomap REQUIRED)\nfind_package(ccd REQUIRED)" FCL_CONFIG "${FCL_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fcl/fclConfig.cmake "${FCL_CONFIG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fcl RENAME copyright)
