vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jiannanya/chlog
    REF v1.0.0
    SHA512 a9c827f0c1b732a70b214746ca681c5759a71e4b759bfc95a5b0e4c8ac9b1b0b93c83e88ba0e46985d27774abe486cd15f3d93dbe253dd3024039e90f27d223d
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCHLOG_BUILD_EXAMPLES=OFF
        -DCHLOG_BUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/chlog
)

# Header-only: remove empty lib directories created by CMake install/export.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")

# Header-only: remove debug tree if produced.
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
