vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF d64a0c948593c0555115f60c79225c0b9ae09510
    SHA512 3794cb78a1422bfc065037abbae81259e6061ba7b12ebd7b88581118e8eeebaf92d80cf7793b0f9f1da6754baf52835a6891663593dd0b0a38009a9cb141082b
    HEAD_REF master
    PATCHES
        cross-build.diff
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d     INFOWARE_USE_D3D
        opencl  INFOWARE_USE_OPENCL
        opengl  INFOWARE_USE_OPENGL
        x11     INFOWARE_USE_X11
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DHOST_PCI_DATA=${CURRENT_HOST_INSTALLED_DIR}/share/${PORT}/pci_data.hpp")
else()
    acquire_pciids(pciids_path)
    list(APPEND FEATURE_OPTIONS "-DINFOWARE_PCI_IDS_PATH=${pciids_path}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINFOWARE_EXAMPLES=OFF
        -DINFOWARE_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=1
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
