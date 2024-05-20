vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HdrHistogram/HdrHistogram_c
    REF ${VERSION}
    SHA512 2ede4b8412c4f0070d555515498e163397de5edebe7560eaea13adcb95a52b7fea99686aed06bbca0c6e8afdf65715483c3889d750f6b5b727bcf43c4fbe18d4
    HEAD_REF main
)

if("log" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DHDR_LOG_REQUIRED=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DHDR_LOG_REQUIRED=DISABLED")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND FEATURE_OPTIONS "-DHDR_HISTOGRAM_BUILD_STATIC:BOOL=OFF")
    list(APPEND FEATURE_OPTIONS "-DHDR_HISTOGRAM_INSTALL_STATIC:BOOL=OFF")
else()
    list(APPEND FEATURE_OPTIONS "-DHDR_HISTOGRAM_BUILD_SHARED:BOOL=OFF")
    list(APPEND FEATURE_OPTIONS "-DHDR_HISTOGRAM_INSTALL_SHARED:BOOL=OFF")
endif()

# Do not build tests and examples
list(APPEND FEATURE_OPTIONS "-DHDR_HISTOGRAM_BUILD_PROGRAMS:BOOL=OFF")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME hdr_histogram
    CONFIG_PATH lib/cmake/hdr_histogram
)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/COPYING.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# hdr_histogram needs zlib only for 'log' option, but cmake-config.in contains a hardcoded dependecy on zlib
if("log" IN_LIST FEATURES)
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hdr_histogram/hdr_histogram-config.cmake" "find_package(ZLIB)" "")
endif()
