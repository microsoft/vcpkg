vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF d64a0c948593c0555115f60c79225c0b9ae09510
    SHA512 3794cb78a1422bfc065037abbae81259e6061ba7b12ebd7b88581118e8eeebaf92d80cf7793b0f9f1da6754baf52835a6891663593dd0b0a38009a9cb141082b
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d     INFOWARE_USE_D3D
        opencl  INFOWARE_USE_OPENCL
        opengl  INFOWARE_USE_OPENGL
        x11     INFOWARE_USE_X11
)

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINFOWARE_EXAMPLES=OFF
        -DINFOWARE_TESTS=OFF
        "-DGIT_EXECUTABLE=${GIT}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
