vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/rhasheq
    REF             c42b672daf9bb1525cb94645244a09344c2a7363
    SHA512          55947069a67e7de8561b92bad753481402dd353aa40b06719346fa1247d8d0a5073a8a3e38419e7d9028684c091eb23b11b254fea836383a24ce8dcfe0cffefc
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/rhasheq"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
