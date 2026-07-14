vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ai-university-aiu/causalontology
    REF "v${VERSION}"
    SHA512 3ab48e0d45ea1f33f6e84bd13755fa6637fd9fe945e3065799747f1a504c8e0249b1df899ec1c68248145e74b3ba6f1656a22b73e89d0e4b329f1b6e580b94c2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME causalontology CONFIG_PATH lib/cmake/causalontology)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
