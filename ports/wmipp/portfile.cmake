vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sonodima/wmipp
    REF v1.0.0
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/wmipp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/wmipp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
