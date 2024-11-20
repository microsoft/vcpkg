vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/logging/log4cxx/${VERSION}/apache-log4cxx-${VERSION}.tar.gz"
    FILENAME "apache-log4cxx-${VERSION}.tar.gz"
    SHA512 bd481d69e29b3c8908bbc91489bf4e752e6edb147404454c0e88fd8f107d68ae5a98e220ab912692e555ca071d1cff7fb99ffa51194cfa7d070593ce6285d2b0
)

vcpkg_download_distfile(MAKE_PKG_CONFIG_SUPPORT_OPT_IN
  URLS https://github.com/apache/logging-log4cxx/commit/4642a50c70b6cbd9b68d7e8dace9c049c8198b07.patch?full_index=1
  SHA512 4b3628d98d233a2e68d1183a8bb2156c2f1e6f80ab50cfe75a6df799d14bc3c7ba028fbb7ff524c56530a2260be37fd9f3d089422027987b5c8c36e9978c254c
  FILENAME Make_pkg_config_support_opt_in-4642a50c70b6cbd9b68d7e8dace9c049c8198b07.patch
)

vcpkg_extract_source_archive(
    SOURCE_PATH ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-find-package.patch
        ${MAKE_PKG_CONFIG_SUPPORT_OPT_IN}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qt        LOG4CXX_QT_SUPPORT
        fmt       ENABLE_FMT_LAYOUT
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLOG4CXX_INSTALL_PDB=OFF # Installing pdbs failed on debug static. So, disable it and let vcpkg_copy_pdbs() do it
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/log4cxx)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_fixup_pkgconfig()
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/log4cxxConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/log4cxxConfig.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(expat CONFIG)
${_contents}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
