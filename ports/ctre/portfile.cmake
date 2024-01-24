vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF "v${VERSION}"
    SHA512 bc476728dbf7b099ad8fa547f586510f2994fb05d7c1d1334efd8bd49c041909d172097a447fde7ebb5b7588b462339c4aefc7a50d2b75945bc328773f964720
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTRE_BUILD_TESTS=OFF
        -DCTRE_BUILD_PACKAGE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/ctre")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
