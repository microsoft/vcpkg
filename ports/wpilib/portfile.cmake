vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF d37f990ce3a8a36bc791dd989dcea2868759e556
    SHA512 0d22ad2fe80973935e87e4864acaacfd96023aa11b77ba84f0a39dde17ba9d86f864971d8f1c9f4a6a1c56db59758cac112d645822da8e0b34b41b065332dff1
    PATCHES 
        fmtlib-fix.patch # https://github.com/wpilibsuite/allwpilib/pull/5429
        no-drake.patch # https://github.com/wpilibsuite/allwpilib/pull/5427
        fix-unsed-variable.patch # https://github.com/wpilibsuite/allwpilib/pull/5430
        fix-fmtlib-10.patch # https://github.com/wpilibsuite/allwpilib/pull/5433
        fix-libuv.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cameraserver WITH_CSCORE
    allwpilib WITH_SIMULATION_MODULES
    allwpilib WITH_WPILIB
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES jinja2)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
      -DWITH_JAVA=OFF
      -DWITH_EXAMPLES=OFF
      -DWITH_TESTS=OFF
      -DWITH_GUI=OFF
      -DWITH_SIMULATION_MODULES=OFF
      -DUSE_SYSTEM_FMTLIB=ON
      -DUSE_SYSTEM_LIBUV=ON
      -DUSE_SYSTEM_EIGEN=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME wpilib)
vcpkg_cmake_config_fixup(PACKAGE_NAME ntcore)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpimath)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpinet)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpiutil)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
