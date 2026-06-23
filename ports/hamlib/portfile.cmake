vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Hamlib/Hamlib
    REF "${VERSION}"
    SHA512 11522382a00f490849a788e8352ac445883f7b86a9fd6f6e17c063721a1a53819f208a21c4b6623d4485946cf9446eccddfee8605d60f96381b4ac7cbee398da
)

vcpkg_list(SET options)
if("usb" IN_LIST FEATURES)
    list(APPEND options --with-libusb=yes)
else()
    list(APPEND options --with-libusb=no)
endif()
if("xml" IN_LIST FEATURES)
    list(APPEND options --with-xml-support=yes)
else()
    list(APPEND options --with-xml-support=no)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
        --with-cxx-binding=yes
        --with-indi=no     # needs libindi/libnova
        --with-readline=no # needs readline
        --enable-html-matrix=no  # needs libgd
        --enable-usrp=no

)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
