vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simonbrunel/qtpromise
    REF "v${VERSION}"
    SHA512 0d6316ec9503a7781b4d9e615e6d538b21b6282a76e5e28e3f323bcdb740e6f66e6c55944e31fc62cec7cc25a90b0f7318277f044a630500202971ca6e2e85b6
    HEAD_REF master
    PATCHES
        patches/install_headers.patch
        patches/remove_error_flags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}" 
    OPTIONS 
        -DQTPROMISE_HEADER_INSTALL_DESTINATION="${CURRENT_PACKAGES_DIR}/include/${PORT}"
        -DQTPROMISE_HEADER_INSTALL_COMPONENTS="Release"
)
vcpkg_cmake_install()

set(USE_QT_VERSION "6") # for Qt5, replace this number with 5, and replace the dependency on port qtbase in vcpkg.json with port qt5-base
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
