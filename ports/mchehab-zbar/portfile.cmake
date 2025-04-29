vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mchehab/zbar
    REF "${VERSION}"
    SHA512 2dd607afbb1e52346bfb740f916c8616112d14153f071f82458b7c653f647b332290a5089543abebfe1c7679eae98b349a84777185d61cfb9ff275bfecc6e08f
    HEAD_REF master
    PATCHES
        windows.patch
        x64.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
    set(ENV{AUTOPOINT} true) # true, the program
    set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_HOST_INSTALLED_DIR}/share/gettext/aclocal/\"")
    # Simulate the relevant effects of (interactive) `gettextize`.
    file(TOUCH "${SOURCE_PATH}/po/Makefile.in.in")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    ADD_BIN_TO_PATH # checking for working iconv
    OPTIONS
        ${options}
        --without-dbus
        --without-gtk
        --without-imagemagick
        --without-java
        --without-jpeg
        --without-python
        --without-qt
        --disable-video
        --without-xv
    OPTIONS_RELEASE
        --disable-assert
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/tools"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
