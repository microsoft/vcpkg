vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF ${VERSION}
    SHA512 1493b68929d3cb4e97c0180ef6f111ae4edbbee072ab78223976005b8402e4e7b56d94f013fbbc009f4db2652167fa3b4ba3c33d4029572ebbe61a36df9da9e4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/exprtk.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
