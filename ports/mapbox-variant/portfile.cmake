vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/variant
    REF a2a4858345423a760eca300ec42acad1ad123aa3 # v1.2.0
    SHA512 6d1ad2f37e137c42592dbd618a3871008d4f83b3cb0d6f05a9c469a6a987ed3fc7f0416ae341646d73e69426903a5a4f64b9f41ae739fd940bbd304dfcae289e
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-mapbox-variant-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/unofficial-mapbox-variant" PACKAGE_NAME "unofficial-mapbox-variant")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSE_1_0.txt")
