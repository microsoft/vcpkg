vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sfcgal/SFCGAL
    REF "v${VERSION}"
    SHA512 4cb50c58ac3174d487165c6f42af34534340adaab25d1dc2f3ef889727e3b996aaf8c9545455655eba4dc3cd641cb5c2dc46057570a1e9671059c18b18942838
    HEAD_REF master
    )

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SFCGAL_USE_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DSFCGAL_BUILD_TESTS=OFF
        -DSFCGAL_WITH_EIGEN=ON
        "-DSFCGAL_USE_STATIC_LIBS=${SFCGAL_USE_STATIC_LIBS}"
        -DBUILD_TESTING=OFF
    )

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SFCGAL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/sfcgal-config" "${CURRENT_PACKAGES_DIR}/debug/bin/sfcgal-config")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
