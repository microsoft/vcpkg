vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokkos/mdspan
    REF aced2cebd362a1e15830da030bd16748131d28bd # stable as of 2021-11-03
    SHA512 a1950430be537497fb84c4a8c5e681cacead93512775098f38ea6c1a20b95d0f7110d9d0802fbdcf8ce3c40ade766cc697773f6ea6fcf8c363b3ebee55620f7c
    HEAD_REF stable
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mdspan)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
