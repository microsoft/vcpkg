include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF d144944d1b81535ed78aafbb12800614500caf43
    SHA512 ae4db72052843c9c53e62a97d67f5aa0a86f4c4e288ecf608dbdc7798a4a64a9929406f14d5932a27010676715ebb2ef03a39e71f69e834073fc503d0f55ce30
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
