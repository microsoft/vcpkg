vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flexible-collision-library/fcl
    REF 97455a46de121fb7c0f749e21a58b1b54cd2c6be # 0.6.1
    SHA512 1ed1f43866a2da045fcb82ec54a7812c3fc46306386bc04ccf33b5e169773743b2985997373a63bf480098a321600321fdf5061b1448b48e993cf92cad032891
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
