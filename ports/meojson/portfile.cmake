#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MistEO/meojson
    REF v4.4.1
    SHA512 c6f7ec05e754a68df75d1743c874e503098cac093f24403014e7759391d19733a281277fdd7b7789b21fa060892f3fc7bc107bb742754eb80add3969a12cf872
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/meojson"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/meojson-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")