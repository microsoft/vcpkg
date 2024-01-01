vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alpaka-group/alpaka
    REF 1.0.0
    SHA512 42e326fa07a741761c334e43ed03e9b950a580ffa86c005f20f9e0887bc648c189b5937ce1a9c08de6a8f295375d771077a709d5adfa14bea46af622985a196d
    HEAD_REF develop
)
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}")
    
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/alpaka")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
