vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF "v${VERSION}"
    SHA512 fa7a8b2d909ff754b591be2d5dffa6056bdcfc58738876cb7358e329187a30d46cf27c2b1387d57d58cc02248cf07e46f17bb27a532c6b3523c82ef8367f66bf
    HEAD_REF master
    PATCHES
        dependencies.diff
        glew-no-glu.diff
        pystring.diff
)
file(GLOB modules "${SOURCE_PATH}/share/cmake/modules/Find*.cmake")
list(REMOVE_ITEM modules "${SOURCE_PATH}/share/cmake/modules/FindExtPackages.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/share/cmake/modules/install" ${modules})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   OCIO_BUILD_APPS
        tools   VCPKG_LOCK_FIND_PACKAGE_OpenGL
)

if(NOT VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
    list(APPEND FEATURE_OPTIONS -DOCIO_USE_SSE2NEON=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOCIO_BUILD_DOCS:BOOL=OFF
        -DOCIO_BUILD_GPU_TESTS:BOOL=OFF
        -DOCIO_BUILD_JAVA:BOOL=OFF
        -DOCIO_BUILD_NUKE:BOOL=OFF
        -DOCIO_BUILD_OPENFX:BOOL=OFF
        -DOCIO_BUILD_PYTHON:BOOL=OFF
        -DOCIO_BUILD_TESTS:BOOL=OFF
        -DOCIO_DIRECTX_ENABLED:BOOL=OFF
        -DOCIO_INSTALL_EXT_PACKAGES=NONE
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenImageIO=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        # only used for OCIO_BUILD_APPS
        CMAKE_DISABLE_FIND_PACKAGE_GLUT
        CMAKE_DISABLE_FIND_PACKAGE_OpenImageIO
        OCIO_DIRECTX_ENABLED
        VCPKG_LOCK_FIND_PACKAGE_OpenGL

)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/OpenColorIO")
vcpkg_fixup_pkgconfig()

set(dll_import 0)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(dll_import 1)
endif()
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/OpenColorIO/OpenColorABI.h"
    "ifndef OpenColorIO_SKIP_IMPORTS"
    "if ${dll_import}"
)

if(OCIO_BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES ociomergeconfigs ocioarchive ociobakelut ociocheck ociochecklut ocioconvert ociocpuinfo ociolutimage ociomakeclf ocioperf ociowrite
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/ocio"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/ext/xxHash/src/include/xxhash.h"
    "${SOURCE_PATH}/ext/sampleicc/src/include/iccProfileReader.h"
    "${SOURCE_PATH}/ext/sampleicc/src/include/icProfileHeader.h"
)
