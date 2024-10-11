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
        cmake-package.diff
        devendor.diff
        disable-tests.diff
        file_formats.diff
        int_64.diff
        limits.diff
        mingw.diff
        omit-broken-install.diff
        openjpeg.diff
)
file(GLOB_RECURSE vendored_sources "${SOURCE_PATH}/v3p/*.c" "${SOURCE_PATH}/v3p/*.cpp" "${SOURCE_PATH}/v3p/*.cxx")
list(FILTER vendored_sources EXCLUDE REGEX "/(netlib|openjpeg2)/")
file(REMOVE_RECURSE ${vendored_sources})

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        core-imaging  VXL_BUILD_CORE_IMAGING
        openjpeg      ENABLE_OPENJPEG
)

if(VCPKG_TARGET_IS_MINGW)
    list(APPEND options -DVXL_HAS_DBGHELP_H=FALSE)  # needs patches
endif()

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
        -DVCL_HAS_LFS=${VCL_HAS_LFS}
        -DVXL_BUILD_CONTRIB=OFF
        -DVXL_BUILD_EXAMPLES=OFF
        -DVXL_HAS_SSE2_HARDWARE_SUPPORT=${VXL_HAS_SSE2_HARDWARE_SUPPORT}
        -DVXL_FORCE_V3P_BZLIB2=OFF
        -DVXL_FORCE_V3P_CLIPPER=OFF
        -DVXL_FORCE_V3P_DCMTK=OFF
        -DVXL_FORCE_V3P_GEOTIFF=OFF
        -DVXL_FORCE_V3P_J2K=OFF
        -DVXL_FORCE_V3P_JPEG=OFF
        -DVXL_FORCE_V3P_OPENJPEG2=ON  # vendored 1.2; vxl needs old API.
        -DVXL_FORCE_V3P_PNG=OFF
        -DVXL_FORCE_V3P_TIFF=OFF
        -DVXL_FORCE_V3P_ZLIB=OFF
        -DVXL_USE_DCMTK=OFF
        -DVXL_USE_GEOTIFF=ON
        -DVXL_USE_WIN_WCHAR_T=${USE_WIN_WCHAR_T}
    MAYBE_UNUSED_VARIABLES
        ENABLE_OPENJPEG
        VXL_USE_DCMTK
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/vxl/cmake)
vcpkg_copy_pdbs()

file(COPY "${SOURCE_PATH}/vcl/vcl_msvc_warnings.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vxl/vcl")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Don't provide source dir; test lib not installed.
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/vxl/vcl/vcl_where_root_dir.h")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(file_list "${SOURCE_PATH}/core/vxl_copyright.h")
if("openjpeg" IN_LIST FEATURES)
    file(COPY_FILE "${SOURCE_PATH}/v3p/openjpeg2/license.txt" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/openjpeg2 license.txt")
    vcpkg_list(APPEND file_list "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/openjpeg2 license.txt")
endif()
vcpkg_install_copyright(FILE_LIST ${file_list} COMMENT [[
vcl includes Netlib software from https://www.netlib.org/. Most netlib software
packages have no restrictions on their use but it is recommended to check with
the authors to be sure. (https://www.netlib.org/misc/faq.html#2.3)
]])
