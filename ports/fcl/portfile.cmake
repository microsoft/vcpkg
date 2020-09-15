vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF a13c681e41eb8180cba7d4fd32637511f588cb82 #v0.6.0
    SHA512 b0fe70f411871ff50b6e5978c01e5849099bec7b68983c6d1ff1afa1628980eaabafd59748ee06e4337efeb77dba6c65af93868a5fc5df980a133a3f667ddccf
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(FCL_STATIC_LIBRARY ON)
else()
    set(FCL_STATIC_LIBRARY OFF)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(FCL_USE_X64_SSE ON)
else()
    set(FCL_USE_X64_SSE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFCL_STATIC_LIBRARY=${FCL_STATIC_LIBRARY}
        -DFCL_BUILD_TESTS=OFF
        -DFCL_USE_X64_SSE=${FCL_USE_X64_SSE}
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)