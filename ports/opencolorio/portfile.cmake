vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF v2.1.1
    SHA512 86585ec860d460b158f24efb82f202deced7ce96a6bfefd42f39cad9c112add68cca6935f383f5d718c07fe1c121d8ed8b0d2069321f1dafb8ce68b49bc75194
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        fix-buildTools.patch
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME OpenColorIO CONFIG_PATH "lib/cmake/OpenColorIO")

vcpkg_copy_pdbs()

# Clean redundant files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/OpenColorIOConfig.cmake"
    "${CURRENT_PACKAGES_DIR}/OpenColorIOConfig.cmake"
)
if(OCIO_BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES ociowrite ociomakeclf ociochecklut ociocheck ociobakelut
        AUTO_CLEAN
    )
endif()

vcpkg_fixup_pkgconfig()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ocio/setup_ocio.sh" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../../")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
