vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sfcgal/SFCGAL
    REF "v${VERSION}"
    SHA512 8b629df31cef1b3b5538eb5a00b51be9553595ad52857030298dbb08bba2997d25a91f579f5a3a9168563f3833f18065fec5089f59cd8994abe99e4cfd421f25
    HEAD_REF master
    )

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SFCGAL_USE_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DSFCGAL_BUILD_TESTS=OFF
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
