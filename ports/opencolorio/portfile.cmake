
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF 0645fdd6b5279ab94851af0c56919ff9800e0c38 # v2.0.1
    SHA512 51568e21eaf863747f67fbcffa7f42ba32f5892e8295dac6c9deb0f6205f57c231ea34ce028d84915e4be2f2773e362b74eaf057c2e4cf3ad4b60bf13a0b73db
    HEAD_REF master
    PATCHES
        fix-pystring-name.patch
        use-find-openxer.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools OCIO_BUILD_APPS
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOCIO_BUILD_NUKE:BOOL=OFF
        -DOCIO_BUILD_DOCS:BOOL=OFF
        -DOCIO_BUILD_TESTS:BOOL=OFF
        -DOCIO_BUILD_GPU_TESTS:BOOL=OFF
        -DOCIO_BUILD_PYTHON:BOOL=OFF
        -DOCIO_INSTALL_EXT_PACKAGES=NONE
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenImageIO=On
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Clean redundant files
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)
if (OCIO_BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES ociowrite ociomakeclf ociochecklut ociocheck ociobakelut
        AUTO_CLEAN
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)