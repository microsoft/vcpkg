set(VCPKG_BUILD_TYPE release)

string(REPLACE "." ";" version_components "${VERSION}")
list(GET version_components 0 version_major)
list(GET version_components 1 version_minor)
list(GET version_components 2 version_patch)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stillwater-sc/universal
    REF "v${VERSION}"
    SHA512 099b634b2242243ac1319e5b6aafb5f3787ab1c03ad9b0cf3abbeec9eb5773d9efc64f1f80c1c566d112f6c77bea55de638ea38a0edc3eb98311ab4e89b0bd85
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNIVERSAL_ENABLE_TESTS=OFF
        -DUNIVERSAL_VERBOSE_BUILD=OFF
        "-DUNIVERSAL_VERSION_MAJOR=${version_major}"
        "-DUNIVERSAL_VERSION_MINOR=${version_minor}"
        "-DUNIVERSAL_VERSION_PATCH=${version_patch}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH CMake PACKAGE_NAME universal)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/universal/internal/variablecascade"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
