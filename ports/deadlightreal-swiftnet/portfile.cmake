vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 b68ddb380b346798bd8841ff726d17e504e81673cf5f9ecf58700234e2f63afb762181fe4e9a2c8e6955c730f19f224bab9ac98afde793757dc8cdb7132cddfe
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
