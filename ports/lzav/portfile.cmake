vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 f3882fa13a63aadec89b627a941c1bd6c35384aeb79baad61fe558c92b0481103a7b78bbfd880ce72d030a9e0fb7293fed789a5ca33476d303849376da5d9e96
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/lzav")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
