if(VCPKG_TARGET_IS_WINDOWS)
    # Cf. https://vxl.github.io/vxl-users-faq.html
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vxl/vxl
    REF dac1c7ed8e183e9c6de8b928c8b0294a7bd1d8ee # v2.0.2
    SHA512 4c6f6dcd793a50cbbc9c7f61c561ed4a747ded67e3dceb09792998c0f0d4294445a441fed668d59297560f196274b1c25593ce67b0aa7597cbb773328e8612c0
    HEAD_REF master
    PATCHES
        clipper.diff
        disable-tests.diff
        file_formats.diff
        geotiff.diff
        int_64.diff
        limits.diff
        mingw.diff
        omit-broken-install.diff
        openjpeg.diff
        rply.diff
)
file(GLOB_RECURSE vendored_sources "${SOURCE_PATH}/v3p/*.c" "${SOURCE_PATH}/v3p/*.cpp" "${SOURCE_PATH}/v3p/*.cxx")
list(FILTER vendored_sources EXCLUDE REGEX "/netlib/")
file(REMOVE_RECURSE ${vendored_sources})

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        core-imaging  VXL_BUILD_CORE_IMAGING
        openjpeg      VXL_FORCE_V3P_OPENJPEG2  # vendored legacy 1.2 lib
)

set(USE_WIN_WCHAR_T OFF)
if(VCPKG_TARGET_IS_WINDOWS)
    set(USE_WIN_WCHAR_T ON)
endif()

# Avoid try-run which doesn't work for cross-builds.
# Users may override with VCPKG_CMAKE_CONFIGURE_OPTIONS.
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "x64" VXL_HAS_SSE2_HARDWARE_SUPPORT)
set(VCL_HAS_LFS ON)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCL_HAS_LFS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DBUILD_TESTING=OFF
        -DCMAKE_POLICY_DEFAULT_CMP0120=OLD  # vxl needs WriteCompilerDetectionHeader
        -DVXL_BUILD_EXAMPLES=OFF
        -DVXL_HAS_SSE2_HARDWARE_SUPPORT=${VXL_HAS_SSE2_HARDWARE_SUPPORT}
        -DVCL_HAS_LFS=${VCL_HAS_LFS}
        -DVXL_FORCE_V3P_BZLIB2=OFF
        -DVXL_USING_NATIVE_BZLIB2=ON
        -DVXL_FORCE_V3P_CLIPPER=OFF
        -DVXL_FORCE_V3P_DCMTK=OFF
        -DVXL_FORCE_V3P_GEOTIFF=OFF
        -DVXL_FORCE_V3P_J2K=OFF
        -DVXL_FORCE_V3P_JPEG=OFF
        -DVXL_FORCE_V3P_PNG=OFF
        -DVXL_FORCE_V3P_TIFF=OFF
        -DVXL_FORCE_V3P_ZLIB=OFF
        -DVXL_USE_DCMTK=OFF # TODO : need fix dcmtk support to turn on
        -DVXL_USE_GEOTIFF=ON
        -DVXL_USE_WIN_WCHAR_T=${USE_WIN_WCHAR_T}
    MAYBE_UNUSED_VARIABLES
        VXL_USE_DCMTK
        VXL_USING_NATIVE_BZLIB2
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/vxl/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Don't provide source dir; test lib not installed.
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/vxl/vcl/vcl_where_root_dir.h")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vxl/VXLConfig.cmake" "# ${CURRENT_BUILDTREES_DIR}" "")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/core/vxl_copyright.h")
