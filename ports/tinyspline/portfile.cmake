vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msteinbeck/tinyspline
    REF v0.4.0
    SHA512 45c3e6937c0c48c3a6953cea26f31a0217a3943f5bca3b4432010b615d30d7e46081625409917a15cf88d671c1c0e0c9c3e61a65a81c842a9a36c2acd8fc6c26
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYSPLINE_BUILD_EXAMPLES=OFF
        -DTINYSPLINE_BUILD_TESTS=OFF
        -DTINYSPLINE_BUILD_DOCS=OFF
        -DTINYSPLINE_WARNINGS_AS_ERRORS=OFF
        -DTINYSPLINE_INSTALL_LIBRARY_DIR=lib
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tinyspline DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME tinysplinecxx CONFIG_PATH lib/cmake/tinysplinecxx)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
