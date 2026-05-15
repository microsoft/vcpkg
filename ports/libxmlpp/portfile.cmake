vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libxmlplusplus/libxmlplusplus
    REF ${VERSION}
    SHA512 ad164deebcf874b54fcf2923c672fe95ab7e397bc17bf6f7079899e8732eb4665e78b6477671cf481bbcb301db146e83c25b8c159da086dd2dd2cf32bba12ffa
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild-documentation=false
        -Dbuild-manual=false
        -Dvalidation=false # Validate the tutorial XML file
        -Dbuild-examples=false
        -Dbuild-tests=false
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
