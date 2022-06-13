vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/Ashes
    REF 0f8ad8edec1b0929ebd10247d3dd0a9ee8f8c91a
    HEAD_REF master
    SHA512 9f34c2f6760a74eb34fc02c5007af41a089ac8b01716f1ba3670014984ab277f02c4bbf14ce3f5996a164d24c1eb8edd525cb1c5da9fc0edbf2ccce3024cb11a
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 77734eff73c8bb9861591a9e910f34f2bafa5563
    HEAD_REF master
    SHA512 f6110eafc8476f41490f7f9087a83ddf90d21f3cbf455edafd02e4805d3dd7f22ed955b8cba8a26600f080de06b19ce6c712e36f03c825fd3c4015b74d030e72
)

file(REMOVE_RECURSE "${SOURCE_PATH}/CMake")
file(COPY "${CMAKE_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/CMake")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DVCPKG_PACKAGE_BUILD=ON
        -DASHES_BUILD_TEMPLATES=OFF
        -DASHES_BUILD_TESTS=OFF
        -DASHES_BUILD_INFO=OFF
        -DASHES_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ashes)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
