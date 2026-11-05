vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ColleagueRiley/RGFW
    REF "${VERSION}"
    SHA512 cb930a735ccfedcd1fd1ab5d45cf5f90c02d3ad88a550a2e36e210a10184aa6cd4abac61700ea7481be9f8a8f8d76aa71fc6b1125c3d95a5d9dbcd565fde56c2
    HEAD_REF master
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
