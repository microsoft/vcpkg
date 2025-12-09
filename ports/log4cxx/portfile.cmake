vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/logging/log4cxx/${VERSION}/apache-log4cxx-${VERSION}.tar.gz"
    FILENAME "apache-log4cxx-${VERSION}.tar.gz"
    SHA512 60cedb41511cca6646682d0041a4dfac1d9e50f29fac7c7d31ef2f6c5c200dba84c010c79aed8a5f453795408a8905669d1a6b2002af6728d5734808369af075
)

vcpkg_extract_source_archive(
    SOURCE_PATH ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qt        LOG4CXX_QT_SUPPORT
        fmt       ENABLE_FMT_LAYOUT
        mprfa     LOG4CXX_MULTIPROCESS_ROLLING_FILE_APPENDER
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
