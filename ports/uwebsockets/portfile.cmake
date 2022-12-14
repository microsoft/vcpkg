# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF c8229b57812714d094426f7841945af4bd7409ee  #v20.31.0
    SHA512 a5509c3f9c6aa038826a87dabb4224e3646fc9c71618ac26783b7555176ddec48ebd1a4f3d9f93315dd3a6d0eb6bd833d7b7a12c7a027de7800048245f1a65e2
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
