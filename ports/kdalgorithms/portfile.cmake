# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDAlgorithms
    REF ${VERSION}
    SHA512 8e7633fb8a42a8e9c9897367fcc19ae506004e60efbdd5cf0f9b8f41b3481d4dc5c71f82d22e71b438878157a15efec9107da0e7868d79f098c5a61830808274
)

file(INSTALL "${SOURCE_PATH}/src/kdalgorithms.h" "${SOURCE_PATH}/src/kdalgorithms_bits"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
