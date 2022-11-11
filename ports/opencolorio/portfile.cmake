vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF v2.1.2
    SHA512 594e808fb1c175d5b14eb540be0dfb6f41cd37b5bf7df8c2d24d44dfe4986643ea68e52d0282eb3b25283489789001a57a201de1eecc1560fc9461780c7da353
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        fix-pkgconfig.patch
)

file(REMOVE "${SOURCE_PATH}/share/cmake/modules/Findexpat.cmake")
file(REMOVE "${SOURCE_PATH}/share/cmake/modules/FindImath.cmake")
file(REMOVE "${SOURCE_PATH}/share/cmake/modules/Findpystring.cmake")
file(REMOVE "${SOURCE_PATH}/share/cmake/modules/Findyaml-cpp.cmake")
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
        TOOL_NAMES ociowrite ociomakeclf ociochecklut ociocheck ociobakelut
        AUTO_CLEAN
    )
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
