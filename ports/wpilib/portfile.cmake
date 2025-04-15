vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF 49b4b064cf98c0e367f54ac8719779cc158eba3a
    SHA512 fe73f09f37cd79e9d6f6f5a4a1a98286f10b12406c1bd7f0d1daf0377d8c7c28217afc97b07842e5c483a2a08586ac699b30ec0d030255f8ab31831aefa6ab58
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_JAVA=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
	-DWITH_GUI=OFF
	-DNO_WERROR=ON
        -DWITH_SIMULATION_MODULES=OFF
	-DUSE_SYSTEM_FMTLIB=ON
	-DUSE_SYSTEM_LIBUV=ON
	-DUSE_SYSTEM_EIGEN=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME apriltag)
vcpkg_cmake_config_fixup(PACKAGE_NAME cameraserver)
vcpkg_cmake_config_fixup(PACKAGE_NAME cscore)
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
