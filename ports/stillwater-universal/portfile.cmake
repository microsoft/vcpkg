set(VCPKG_BUILD_TYPE release)

string(REPLACE "." ";" version_components "${VERSION}")
list(GET version_components 0 version_major)
list(GET version_components 1 version_minor)
list(GET version_components 2 version_patch)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stillwater-sc/universal
    REF "v${VERSION}"
    SHA512 f7173e3d742b4e9275799bce16fed6296e4db3a2a397a705d896841523a6fc3629f4c33ed452b777883944c0c3312c392b6609b949ee4582cf537f8e4cd998d7
    HEAD_REF master
    PATCHES
        fix-install-path.patch
        fix-package-version.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
