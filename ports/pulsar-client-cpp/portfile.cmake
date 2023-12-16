vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/pulsar-client-cpp
    REF "v${VERSION}"
    SHA512 ab257f5e82d3815a232dd73297c6ff032536de3d9e5adec6c53fa0276fc02efb1a84e153278f21881de1d3a786e26c4d4d2aff78c1d3fbf932f4d5b6e8cae9dc
    HEAD_REF main
    PATCHES
      0001-use-find-package.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
option(BUILD_DYNAMIC_LIB ON)
if (MSVC AND BUILD_STATIC_LIB)
    set(BUILD_DYNAMIC_LIB OFF)
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TOOLS=OFF
        -DBUILD_DYNAMIC_LIB=${BUILD_DYNAMIC_LIB}
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

file(COPY "${CURRENT_PORT_DIR}/unofficial-pulsar-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-pulsar/")

vcpkg_copy_pdbs()
