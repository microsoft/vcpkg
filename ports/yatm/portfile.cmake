vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO plekakis/yatm
    REF "${VERSION}"
    SHA512 ccd91b6b603c579c612f202a7ae579b33f25a153fa1bd186533f0ebf18899d1815c24e381cabdfaf3983c68dd3b632227bf3c7d85766edb9f6eeb10c68d965d7
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include" "${CURRENT_PACKAGES_DIR}/include/yatm")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
