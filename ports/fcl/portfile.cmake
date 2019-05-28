include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF d144944d1b81535ed78aafbb12800614500caf43
    SHA512 37a4bb076360c4e913fa4436886c6781fc569e39493a9cb218527a0e4f098501a7cc77653fc8bbb7b4c7cd5d0e6076ee4aed80a5af38602ca6d3fba3f870b9d1
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
  vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/fcl")
endif()


file(READ ${CURRENT_PACKAGES_DIR}/share/fcl/fclConfig.cmake FCL_CONFIG)
string(REPLACE "unset(_expectedTargets)"
               "unset(_expectedTargets)\n\nfind_package(octomap REQUIRED)\nfind_package(ccd REQUIRED)" FCL_CONFIG "${FCL_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fcl/fclConfig.cmake "${FCL_CONFIG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fcl RENAME copyright)
