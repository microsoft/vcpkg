vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borgesdan/xnpp
    REF v0.1.0
    SHA512 14c483b1856d1645356948adccd42cea6ccc91a97041637e1f4751ac8b329034127359d2c87b768485c6b41825aa28764be72583551d20c2832054fcd6af298c
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DXNPP_BUILD_LIB=ON
        -DXNPP_BUILD_APP=OFF
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/Xnpp
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.md"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
