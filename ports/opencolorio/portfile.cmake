vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF "v${VERSION}"
    SHA512 11ad89b3ac30700be58181a0bdd4154a3ae2bf59651edb48629c51c7f1fadf221394abb285efd9b6c259195821a4e531043b266eea36d8fa4382f23c3b54ab6d
    HEAD_REF master
    PATCHES
        # fix-dependency.patch
        fix-del-install-file.patch
        # fix-func-param.patch #https://github.com/AcademySoftwareFoundation/OpenColorIO/pull/1806
        fix-pkgconfig.patch
)

file(REMOVE "${SOURCE_PATH}/share/cmake/modules/Findlcms2.cmake")

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
        -DOCIO_BUILD_OPENFX:BOOL=OFF
        -DOCIO_BUILD_JAVA:BOOL=OFF
        -DOCIO_USE_OPENEXR_HALF:BOOL=OFF
        -DOCIO_INSTALL_EXT_PACKAGES=NONE
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenImageIO=On
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_OpenImageIO
        OCIO_USE_OPENEXR_HALF
)

vcpkg_cmake_install()

set(dll_import 0)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(dll_import 1)
endif()
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/OpenColorIO/OpenColorABI.h"
    "ifndef OpenColorIO_SKIP_IMPORTS"
    "if ${dll_import}"
)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/OpenColorIO")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ocio"
)
if(OCIO_BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES ociowrite ociomakeclf ociochecklut ociocheck ociobakelut ocioarchive ocioconvert ociolutimage ocioperf
        AUTO_CLEAN
    )
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
