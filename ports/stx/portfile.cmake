vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lamarrr/STX
    REF "v${VERSION}"
    SHA512 3cc06118677f9b43bc79e5719d408af8b4d8e729a4da20ee56431bdb8823e73f7eb4d4f961534d0c7329417d9371ebb1255246fc08a65fd67a7eca2b2b8a99a3
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        backtrace    STX_ENABLE_BACKTRACE
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
