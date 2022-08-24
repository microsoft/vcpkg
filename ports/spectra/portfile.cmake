vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yixuan/spectra
    REF v1.0.1
    SHA512 575f90d2ab9c3cbdd4bbfe1abce35a262e319dac8689420859811a169cbfd8f617c80bfcd430aa8a5383c96f338155870a0ad7ac0d5db855c1e822c2d19837b5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/spectra/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
