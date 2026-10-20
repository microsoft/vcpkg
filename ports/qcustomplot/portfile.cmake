vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${VERSION}/QCustomPlot.tar.gz"
    FILENAME "QCustomPlot-${VERSION}.tar.gz"
    SHA512 2e49a9b3f7ab03bcd580e5f3c3ae0d5e8c57d3ccce0ceed9862cde7ea23e2f3672a963af988be60e504cb5aa50bc462e4b28acf577eae41cc6fea2802642dc19
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${VERSION}/QCustomPlot-sharedlib.tar.gz"
    FILENAME "QCustomPlot-sharedlib-${VERSION}.tar.gz"
    SHA512 c661e4a835066fee92b254fbd7b825dbd5c58973189ff2099a01308cb81fe6bf3bac1456f5da91f01c6265f8f548f61b57e237d00a9b5c2c94acf1a024baa18e
)
vcpkg_extract_source_archive(
    SharedLib_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        config.patch
)
file(RENAME "${SharedLib_SOURCE_PATH}" "${SOURCE_PATH}/qcustomplot-sharedlib")

vcpkg_qmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation/sharedlib-compilation.pro"
    QMAKE_OPTIONS
        "${OSX_OPTIONS}"
)
vcpkg_qmake_install()

vcpkg_copy_pdbs()

# Upstream does not provide a CMake config
if(VCPKG_TARGET_IS_MINGW)
    set(library_glob "libqcustomplot*.a")
    set(debug_library_glob "libqcustomplotd*.a")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(library_glob "qcustomplot*.lib")
    set(debug_library_glob "qcustomplotd*.lib")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(library_glob "libqcustomplot${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
    set(debug_library_glob "libqcustomplotd${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
else()
    set(library_glob "libqcustomplot${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    set(debug_library_glob "libqcustomplotd${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
endif()
file(GLOB QCUSTOMPLOT_LIBRARY_RELEASE RELATIVE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/lib/${library_glob}")
file(GLOB QCUSTOMPLOT_LIBRARY_DEBUG RELATIVE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/debug/lib/${debug_library_glob}")
list(LENGTH QCUSTOMPLOT_LIBRARY_RELEASE release_libraries)
list(LENGTH QCUSTOMPLOT_LIBRARY_DEBUG debug_libraries)
if(NOT release_libraries EQUAL 1 OR debug_libraries GREATER 1)
    message(FATAL_ERROR "Unexpected libraries: '${QCUSTOMPLOT_LIBRARY_RELEASE}' '${QCUSTOMPLOT_LIBRARY_DEBUG}'")
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QCUSTOMPLOT_SHARED)
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-qcustomplot-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-qcustomplot/unofficial-qcustomplot-config.cmake" @ONLY)

include(CMakePackageConfigHelpers)
write_basic_package_version_file("${CURRENT_PACKAGES_DIR}/share/unofficial-qcustomplot/unofficial-qcustomplot-config-version.cmake"
    VERSION "${VERSION}"
    COMPATIBILITY SameMajorVersion
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
configure_file(${SOURCE_PATH}/GPL.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
