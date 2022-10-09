vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sciplot/sciplot
    REF f8d779a1110b76c6bdc77edcdc7fa798156a6917 #v0.3.1
    SHA512 fa21895c637bc42071fbd951e1c2ee450798398863626e31015f106077de4ad17dc276d77f2f1a4a7679c055c8cd8caafea513d746ac7ddbb22a16cc9382f39a
    HEAD_REF vcpkg
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSCIPLOT_BUILD_EXAMPLES=OFF
        -DSCIPLOT_BUILD_TESTS=OFF
        -DSCIPLOT_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/sciplot)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
