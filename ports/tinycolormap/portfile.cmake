set(VCPKG_BUILD_TYPE release) # Header only without TINYCOLORMAP_WITH_EIGEN, TINYCOLORMAP_WITH_QT5,
                              # TINYCOLORMAP_WITH_GLM, or TINYCOLORMAP_BUILD_TOOLS
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yuki-koyama/tinycolormap
    REF b79255bf4c0d3557df2c382d0673c0392e6d6951
    SHA512 15c454298ff24b3b5a944ffc28c7695905a883eac4c699e65d54f0dc592548a1c92532ab374cb26db01627343ac6dff0b3030da623a76f01f2e5be025308a940
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
