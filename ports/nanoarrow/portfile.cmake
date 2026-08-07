
vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/arrow/apache-arrow-nanoarrow-${VERSION}/apache-arrow-nanoarrow-${VERSION}.tar.gz"
    FILENAME "apache-arrow-nanoarrow-${VERSION}.tar.gz"
    SHA512 2fbdfe3274da9dcba5e3215ba0a7ff66da9f65395d1800841f0dc9a6bbc00b8cc224f900bcb946c91969b3c6e79d132ad5077c9a537f861502c4763dbffb33b8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty")

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_INSTALL_SHARED)

if ("ipc" IN_LIST FEATURES)
    set(FEATURE_OPTIONS "-DNANOARROW_IPC=ON")
    set(FLATCCRT_OPTIONS "-DNANOARROW_FLATCC_ROOT_DIR=${CURRENT_INSTALLED_DIR}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOARROW_INSTALL_SHARED=${NANOARROW_INSTALL_SHARED}
        -DNANOARROW_DEBUG_EXTRA_WARNINGS=OFF
        ${FEATURE_OPTIONS}
        ${FLATCCRT_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME nanoarrow
    CONFIG_PATH lib/cmake/nanoarrow
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

# Fix bare "flatccrt" in INTERFACE_LINK_LIBRARIES - Windows needs the full path
# Tracked upstream at https://github.com/apache/arrow-nanoarrow/issues/922
if ("ipc" IN_LIST FEATURES AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/nanoarrow/nanoarrow-targets.cmake"
        [[\$<LINK_ONLY:flatccrt>]]
        [[\$<LINK_ONLY:${_IMPORT_PREFIX}/lib/flatccrt.lib>]]
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/NOTICE.txt"
)
