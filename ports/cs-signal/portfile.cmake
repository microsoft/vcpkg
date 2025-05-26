vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO copperspice/cs_signal
    REF "signal-${VERSION}"
    SHA512 75b1f6852f8e75067d91fe33092758dd6c9dad13bde699e5b053e64822add454c6a1a0d1d149e67c0bd5a1f7fb95482ead1c988ec1e1336bf05c57f791fab419
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME cssignal
    CONFIG_PATH cmake/CsSignal
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
