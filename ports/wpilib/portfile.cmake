vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF "v${VERSION}"
    SHA512 7055b38800aa00cf7d44b2ed38367c3b6f1f8c6e5022b7ba34c7088a7710d187358ec2bdfea919524cdd5daba28c875cd8d18d3feec55295881afe79f909d0ad
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        allwpilib          WITH_WPILIB
        cameraserver       WITH_CSCORE
        gui                WITH_GUI
        ntcore             WITH_NTCORE
        protobuf           WITH_PROTOBUF
        simulationmodules  WITH_SIMULATION_MODULES
        wpimath            WITH_WPIMATH
	wpical             WITH_WPICAL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_SYSTEM_EIGEN=OFF
        -DUSE_SYSTEM_LIBUV=ON
	-DUSE_SYSTEM_FMTLIB=ON
        -DWITH_JAVA=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
	-DWITH_BENCHMARK=OFF
        -DNO_WERROR=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME wpiutil)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
