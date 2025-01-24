vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sheredom/subprocess.h
    REF b49c56e9fe214488493021017bf3954b91c7c1f5
    SHA512 5d068660ae6e980d80271c0cecfd6e9057e9b04d1fd5154d60de0de9d062716a6c9b94a8ebadf722b49808b0761d5572d3495990efd18901516820a87f8ddf03
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/subprocess.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
