vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF v${VERSION}
    SHA512 11b5394efbc54e724a48a93d960d69befecf38fd22457074458283e7e42fa011865a80022ff18162e65074e0bf9f008d298471b6ec76636361ba4eadbfdb512c
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cscore WITH_CSCORE
        protobuf WITH_PROTOBUF
        simulation-modules WITH_SIMULATION_MODULES
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES jinja2)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_WERROR=ON
        -DWITH_JAVA=OFF
        -DWITH_DOCS=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DWITH_GUI=OFF
        -DWITH_NTCORE=ON
        -DWITH_WPIMATH=ON
        -DWITH_WPILIB=ON
        -DUSE_SYSTEM_FMTLIB=ON
        -DUSE_SYSTEM_LIBUV=ON
        -DUSE_SYSTEM_EIGEN=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME apriltag)
if ("cscore" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME cameraserver)
    vcpkg_cmake_config_fixup(PACKAGE_NAME cscore)
endif ()
vcpkg_cmake_config_fixup(PACKAGE_NAME hal)
vcpkg_cmake_config_fixup(PACKAGE_NAME ntcore)
vcpkg_cmake_config_fixup(PACKAGE_NAME romiVendordep)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpilib)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpilibc)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpilibNewCommands)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpimath)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpinet)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpiutil)
vcpkg_cmake_config_fixup(PACKAGE_NAME xrpVendordep)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
