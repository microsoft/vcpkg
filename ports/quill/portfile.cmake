vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 a135c1e149e909c4488b096c93240119429154fdc7fd3d3358409f480463036fda43d4a1650e733e1c713e0d2f4af458f9e06b1a33a6f04fa05d5c63cc6c0309
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
