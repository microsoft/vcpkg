vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simonbrunel/qtpromise
    REF "v${VERSION}"
    SHA512 0d6316ec9503a7781b4d9e615e6d538b21b6282a76e5e28e3f323bcdb740e6f66e6c55944e31fc62cec7cc25a90b0f7318277f044a630500202971ca6e2e85b6
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/src" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
configure_file(${CMAKE_CURRENT_LIST_DIR}/unofficial-config.cmake.in ${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake @ONLY)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
