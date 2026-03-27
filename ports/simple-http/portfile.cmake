vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fantasy-peak/simple_http
    REF v0.6.5
    SHA512 636e781d19c268b64a7ef05bed900a817cf02668842a8020558682c7b0839c13def49165256fbd0c22f7402bc1960a946b06dbda04b7e1b6a4d6e54dcfe68860
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
