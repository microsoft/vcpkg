vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Hamlib/Hamlib
    REF "${VERSION}"
    SHA512 84541adc1de2132d272a823c21a80376da8effe0be4afd41e8f4bf4b2bf714b2abf8418ed0d21491f961cbe358cff2718a07b499d6277a9292f81ce2b1eee92f
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
