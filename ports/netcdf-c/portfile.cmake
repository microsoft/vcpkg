vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF "v${VERSION}"
    SHA512 c82d77572a10e8d84f5c2db205f3b486add97195c1c29ee4747a6e435fbfb03e111ddb652e137086db04d820eb7542ffbac310e48fae01474f0892abad099ed6
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        dependencies.diff
        fix-pkgconfig.patch
        mremap.diff
        plugin-install-dir.diff
)
file(GLOB_RECURSE modules "${SOURCE_PATH}/cmake/modules/Find*.cmake")
set(vendored_bzip2 blocksort.c huffman.c crctable.c randtable.c compress.c decompress.c bzlib.c bzlib.h bzlib_private.h)
list(TRANSFORM vendored_bzip2 PREPEND "${SOURCE_PATH}/plugins/")
file(GLOB vendored_tinyxml2 "${SOURCE_PATH}/libncxml/tinyxml2.*")
file(REMOVE ${modules} ${vendored_bzip2} ${vendored_tinyxml2})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dap         NETCDF_ENABLE_DAP
        nczarr      NETCDF_ENABLE_NCZARR
        nczarr-zip  NETCDF_ENABLE_NCZARR_ZIP
        netcdf-4    NETCDF_ENABLE_HDF5
        plugins     NETCDF_ENABLE_PLUGINS
        plugins     NETCDF_ENABLE_FILTER_BZ2
        szip        NETCDF_ENABLE_FILTER_SZIP
        tools       NETCDF_BUILD_UTILITIES
        zstd        NETCDF_ENABLE_FILTER_ZSTD
    )

if(NETCDF_ENABLE_DAP OR NETCDF_ENABLE_NCZARR)
    list(APPEND FEATURE_OPTIONS "-DVCPKG_LOCK_FIND_PACKAGE_CURL=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DVCPKG_LOCK_FIND_PACKAGE_CURL=OFF")
endif()

if(VCPKG_TARGET_IS_UWP)
    string(APPEND VCPKG_C_FLAGS " /wd4996 /wd4703")
    string(APPEND VCPKG_CXX_FLAGS " /wd4996 /wd4703")
endif()
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND FEATURE_OPTIONS "-DHAVE_DIRENT_H=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # netcdf-c configures in the source!
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_PLUGIN_INSTALL=ON
        -DNETCDF_ENABLE_DAP_REMOTE_TESTS=OFF
        -DNETCDF_ENABLE_EXAMPLES=OFF
        -DNETCDF_ENABLE_FILTER_BLOSC=OFF
        -DNETCDF_ENABLE_FILTER_TESTING=OFF
        -DNETCDF_ENABLE_LIBXML2=OFF
        -DNETCDF_ENABLE_S3=OFF
        -DNETCDF_ENABLE_TESTS=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_MakeDist=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_PkgConfig=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_ZLIB=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        ENABLE_PLUGIN_INSTALL
        VCPKG_LOCK_FIND_PACKAGE_CURL
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/netCDF")
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/netcdf.h" "defined(DLL_NETCDF)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/nc-config" "${CURRENT_PACKAGES_DIR}/bin/nc-config") # invalid
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES  nccopy ncdump ncgen ncgen3
        AUTO_CLEAN
    )
else()
    vcpkg_clean_executables_in_bin(FILE_NAMES none)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/lib/libnetcdf.settings"
    "${CURRENT_PACKAGES_DIR}/lib/libnetcdf.settings"
)

set(ncpoco_copyright "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libncpoco COPYRIGHT")
file(COPY_FILE "${SOURCE_PATH}/libncpoco/COPYRIGHT" "${ncpoco_copyright}")
set(ncpoco_source_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libncpoco SourceLicence")
file(COPY_FILE "${SOURCE_PATH}/libncpoco/SourceLicence" "${ncpoco_source_license}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT" "${ncpoco_copyright}" "${ncpoco_source_license}")
