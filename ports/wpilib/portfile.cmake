vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF v${VERSION}
    SHA512 11b5394efbc54e724a48a93d960d69befecf38fd22457074458283e7e42fa011865a80022ff18162e65074e0bf9f008d298471b6ec76636361ba4eadbfdb512c
)

if("allwpilib" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH_APRILTAG
        REPO wpilibsuite/apriltag
        REF da208cc38c1b78fe89861616d44c0692e76b6b8b
        SHA512 8d450d05ea6b65ff690af2424a3fc73e5a5887474058b4983dde5012fad25913ef9a122de897439cc837d59c18c692a8a2b4fa2195bd47f81760cc26828230c5
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cameraserver WITH_CSCORE
        allwpilib WITH_WPILIB
        allwpilib WITH_SIMULATION_MODULES
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
