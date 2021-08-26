if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hypre-space/hypre
    REF v2.19.0
    SHA512 999979bc2e7d32aef7c084fc8508fb818e6f904db0ee3ebf6b8e8132f290201c407aaba0aa89e7bf09e7264f4e99caf04f3147458847de816fc8ffc81dbee2df
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(OPTIONS -DHYPRE_SHARED=ON)
else()
  set(OPTIONS -DHYPRE_SHARED=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        -DHYPRE_ENABLE_HYPRE_BLAS=OFF
        -DHYPRE_ENABLE_HYPRE_LAPACK=OFF
    OPTIONS_RELEASE
        -DHYPRE_BUILD_TYPE=Release
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
    OPTIONS_DEBUG
        -DHYPRE_BUILD_TYPE=Debug
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/HYPRE)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
