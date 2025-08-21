set(VCPKG_BUILD_TYPE release)

set(CONFIGURE_VERSION "5.8.1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scivision/mumps
    REF "v${VERSION}.0"
    SHA512 bb28d9cbd3a355f0f2ec5a1f81f5ad78cbbd66b00832c65adcae2159a3def47227584dba7028fcc42c60b49a2e1cda223ec6b115bbc80959ccff824f0a337053
    PATCHES
      mumps_pc.patch
)

# Copy pkg-config template
file(COPY "${CMAKE_CURRENT_LIST_DIR}/mumps-solver.pc.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DMUMPS_parallel=OFF
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mumps-solver)
vcpkg_copy_pdbs()
#vcpkg_fixup_pkgconfig()

# Install usage file and custom FindModules
#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindMUMPS.cmake"  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
#vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
