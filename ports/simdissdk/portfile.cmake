vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USNavalResearchLaboratory/simdissdk
    REF "simdissdk-${VERSION}"
    SHA512 0edef863aa1c62ff317ce15072f8b036fab7fa65d45325420ae4ec3ff807d7b43b90ade974bae760e0808db5c325af961b066719d3714440df312bfa7909f3c9
    HEAD_REF master
    PATCHES
        0001-SIM-17983-Added-simCore-XmlWriter-writeTag-for-Doubl.patch
        0002-simVis-protect-against-access-of-null-terrain-engine.patch
        0003-simVis-allow-eye-position-transitions-using-osgearth.patch
        0004-SDK-Update-SDK-Version-Number-2-4.patch
        0005-Update-to-comply-with-new-Expression-and-qualified_d.patch
        0006-SDK-Update-to-osgEarth-Expression-Syntax-1-2.patch
        0007-SDK-simData-Protobuf-to-Library-1-3.patch
        0008-SDK-Remove-CreateProtobufLibrary-1-4.patch
        0009-SDK-Beam-Example-resolution-ImGui-sliders-use-int-in.patch
        0010-SDK-Append-Path-for-protobuf-Library-1-2.patch
        0011-SDK-simDataProto-is-now-SHARED-by-default-1-2.patch
        0012-SDK-Preparation-for-Protobuf-29.3-Update-1-5.patch
        0013-SDK-Install-Protobuf-Shared-Objects-1-2.patch
        0014-SDK-Action-Registry-Test-Initializes-Environment.patch
        0015-SIM-18120-Expanded-the-use-of-Fast-Update-for-Memory.patch
        0016-SIM-18112-Fixed-Platforms-With-No-Interpolation.patch
        0017-SDK-Install-of-GDAL-SO-optional.patch
        0018-SDK-CMake-Version-3.21-Minimum-1-7.patch
        0019-SIM-18169-Clean-Up-Pass-on-simData-PlatformUpdate.patch
        0020-SIM-18172-Merge-Simple-simData-Updates-Into-Main-1-7.patch
        0021-SIM-18187-Updated-Category-Data-and-Generic-Data-to-.patch
        0022-SIM-18172-Updated-LobGroup-To-Better-Match-Initial-P.patch
        0023-SIM-18132-simQt-formatToolTip-Now-Supports-a-Text-Ov.patch
        0024-simCore-Add-GPKG-extension-to-GDAL-Image-file-lists.patch
        0025-SDK-Fix-Invalid-Return-Statement.patch
        0026-BAM-Unit-toBase-scalar-fix.patch
        0027-SDK-Update-Examples-to-use-ImGui-1.90.9.patch
        0028-SDK-Remove-GLEW-dependency.patch
        0029-simUtil-DbConfigurationFile-s-use-of-setColorFilter-.patch

        add-fontconfig.patch
        change-install-dir.patch
        change-osgqt-to-osgQOpenGL.patch
        disable-add-executable.patch
        disable-example-imgui.patch
        disable-plugin-webp.patch
        donot-use-static-glew.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdata     BUILD_SIMDATA
        simvis      BUILD_SIMVIS
        simutil     BUILD_SIMUTIL
        simqt       BUILD_SIMQT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINSTALL_THIRDPARTY_LIBRARIES=OFF
        -DBUILD_SDK_EXAMPLES=OFF
    OPTIONS_DEBUG
    MAYBE_UNUSED_VARIABLES
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME simCore 
    CONFIG_PATH lib/cmake/simCore 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMDATA)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simData 
    CONFIG_PATH lib/cmake/simData 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simDataProto 
    CONFIG_PATH lib/cmake/simDataProto 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simNotify 
    CONFIG_PATH lib/cmake/simNotify 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMQT)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simQt 
    CONFIG_PATH lib/cmake/simQt 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
if(BUILD_SIMUTIL)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simUtil 
    CONFIG_PATH lib/cmake/simUtil 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
if(BUILD_SIMVIS)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simVis 
    CONFIG_PATH lib/cmake/simVis 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME SIMDIS_SDK
    CONFIG_PATH lib/cmake
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SIMNOTIFY_SHARED OFF)
    set(SIMCORE_SHARED OFF)
    set(SIMDATA_SHARED OFF)
    set(SIMDATAPROTO_SHARED OFF)
    set(SIMVIS_SHARED OFF)
    set(SIMUTIL_SHARED OFF)
    set(SIMQT_SHARED OFF)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/ExternalSdkProject")

set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
