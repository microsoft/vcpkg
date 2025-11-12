vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 0c67fad499cfad53a9c87c5662f439336d99ae67bcb63240c364dad8cdfeb66f074d46b0b332eb54772cf2fb03795c07d8296a480de5e99053b0471497a32519
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
