if(EXISTS ${CURRENT_INSTALLED_DIR}/share/zbar/copyright)
    message(FATAL_ERROR "${PORT} conflicts with zbar. Please remove zbar before installing ${PORT}.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mchehab/zbar
    REF 0.23.1
    SHA512 ae7741cf750a10cf53dc11abcd482c3885507153ee37f6e3364ed5ed72184ebb009560b8c40d8090603a551fb681700a962838a59ce77d005d080ee49fbfa54b
    HEAD_REF master
    PATCHES
        autoconf.patch
        c99.patch
        issue219.patch
        windows.patch
        x64.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    ADD_BIN_TO_PATH
    ADDITIONAL_MSYS_PACKAGES findutils gettext gettext-devel liblzma tar xz
    OPTIONS
        --disable-video
        --without-gtk
        --without-imagemagick
        --without-java
        --without-python
        --without-qt
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/zbar" "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
