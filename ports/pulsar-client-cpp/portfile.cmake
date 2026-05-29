vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/pulsar/pulsar-client-cpp-${VERSION}/apache-pulsar-client-cpp-${VERSION}.tar.gz"
    FILENAME "apache-pulsar-client-cpp-${VERSION}.tar.gz"
    SHA512 cedb1bbc688b5e18a42b301e69d541f732bac01dce5b3ace4e031ab51488be9543fe03a77efefc8d67811d036920923d47c0c48e8c36f71c3c4d50237c0ffb6c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        disable-warnings.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINTEGRATE_VCPKG=ON
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TOOLS=OFF
        -DBUILD_DYNAMIC_LIB=${BUILD_DYNAMIC_LIB}
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
)

vcpkg_cmake_install()

if (BUILD_STATIC_LIB)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pulsar/defines.h"
        "#ifdef PULSAR_STATIC"
        "#if 1")
endif ()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-pulsar-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-pulsar/unofficial-pulsar-config.cmake" @ONLY)

vcpkg_copy_pdbs()
