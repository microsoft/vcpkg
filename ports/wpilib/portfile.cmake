vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF "v${VERSION}"
    SHA512 11b5394efbc54e724a48a93d960d69befecf38fd22457074458283e7e42fa011865a80022ff18162e65074e0bf9f008d298471b6ec76636361ba4eadbfdb512c
    HEAD_REF main
    PATCHES
        fix-eigen-constexpr.patch
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
        -DNO_WERROR=ON
)

vcpkg_cmake_install()

set(WPI_CONFIG_FILE_PATH "${CURRENT_PACKAGES_DIR}/share/wpilib/wpilib-config.cmake")

file(READ "${WPI_CONFIG_FILE_PATH}" WPI_CONFIG_FILE_CONTENTS)

string(REPLACE "find_dependency(wpilibj)" "" WPI_CONFIG_FILE_CONTENTS "${WPI_CONFIG_FILE_CONTENTS}")

file(WRITE "${WPI_CONFIG_FILE_PATH}" WPI_CONFIG_FILE_CONTENTS)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGE_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
