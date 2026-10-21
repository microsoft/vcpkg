if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hypre-space/hypre
    REF "v${VERSION}"
    SHA512 c1b09a31781ce4e1a411c486424cf7a4df1275d53445ed83d0e4e210dcc87e9c09e17e26cc5ee736aebbd70618674cd3b7dba6736f8e725ba1c3d981869ada24
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" HYPRE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    DISABLE_PARALLEL_CONFIGURE # See 'Autogenerate csr_spgemm_device_numer$ files'
    OPTIONS
        -DHYPRE_SHARED=${HYPRE_SHARED}
        -DHYPRE_ENABLE_HYPRE_BLAS=OFF
        -DHYPRE_ENABLE_HYPRE_LAPACK=OFF
    OPTIONS_RELEASE
        -DHYPRE_BUILD_TYPE=Release
        "-DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    OPTIONS_DEBUG
        -DHYPRE_BUILD_TYPE=Debug
        "-DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/HYPRE)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
