vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/serf/serf-1.3.10.zip"
    FILENAME "serf-1.3.10.zip"
    SHA512 82e1c7342b0fa102c0e853989da0f6b590584e5a1d7737f891edd1d49b2a3ec271fd71f2642813455f73230c57230aebdc3a83808335dd53c5ce9fdab8506e2f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        "serf-msbuild.patch"
)

vcpkg_install_msbuild(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "serf.sln"
    TARGET "serf"
    PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    OPTIONS
        /p:CURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
        /p:VCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Header files
file(GLOB_RECURSE INCLUDES "${SOURCE_PATH}/*.h")
file(COPY ${INCLUDES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/serf")

configure_file("${SOURCE_PATH}/build/serf.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/serf.pc" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/serf-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
