# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pravila00/enum-string
    REF 3eec46f5520c287ee46692ea1d41833cbe0d80f2
    SHA512 5b29c27b8ceb358bae5a2b4fb5d198b7b4cd8a7c9926bd7685c27650da5cda9f6dc85b6a9694fe151d03b22e3230d5f3faf9143e865dffc0795b2952fca5fc0f
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/EnumString.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
