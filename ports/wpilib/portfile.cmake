vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF 165ebe4c79c437c7ba6c03af4a88a8c8680f742a
    SHA512 f6ee07db0a119a7ac5876c4b0cf74abfb6af635d3d3ba913300138c450f62f6595ac4849bc499346f9f0179cc563f548a5e8a9a47122af593b425af453afd99f
    PATCHES
        no-werror.patch
        windows-install-location.patch
        missing-find_dependency.patch
        fix-usage.patch
)

if("allwpilib" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH_APRILTAG
        REPO wpilibsuite/apriltag
        REF e55b751f2465bd40a880d9acb87d24289e2af89e
        SHA512 a5d824d11312f7f5229bad162349586e9c855cd1dc03f33235c045f2d5235932227eb17f9e9c801b46a28991cddcf7ad16d39549560251d7d9d52ce72f094a73
    )
endif()

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
        "-DFETCHCONTENT_SOURCE_DIR_APRILTAGLIB=${SOURCE_PATH_APRILTAG}"
    MAYBE_UNUSED_VARIABLES
        FETCHCONTENT_SOURCE_DIR_APRILTAGLIB
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME wpilib)
vcpkg_cmake_config_fixup(PACKAGE_NAME ntcore)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpimath)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpinet)
vcpkg_cmake_config_fixup(PACKAGE_NAME wpiutil)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
