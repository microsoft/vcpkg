vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF "v${VERSION}"
    SHA512 11b5394efbc54e724a48a93d960d69befecf38fd22457074458283e7e42fa011865a80022ff18162e65074e0bf9f008d298471b6ec76636361ba4eadbfdb512c
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cameraserver WITH_CSCORE
        allwpilib WITH_SIMULATION_MODULES
        allwpilib WITH_WPILIB
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES jinja2)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWITH_JAVA=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DWITH_GUI=OFF
        -DWITH_SIMULATION_MODULES=OFF
        -DUSE_SYSTEM_FMTLIB=ON
        -DUSE_SYSTEM_LIBUV=ON
        -DUSE_SYSTEM_EIGEN=ON
	-DWITH_NTCORE=ON
	-DWITH_WPILIB=ON
	-DWITH_CSCORE=ON
	-DWITH_WPIMATH=ON
	-DWITH_WPIUNITS=ON
	-DNO_WERROR=ON
	-DWITH_PROTOBUF=ON
	-DWITH_WPILIB=ON
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
