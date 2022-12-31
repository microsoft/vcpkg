if(EXISTS ${CURRENT_INSTALLED_DIR}/share/zbar/copyright)
    message(FATAL_ERROR "${PORT} conflicts with zbar. Please remove zbar before installing ${PORT}.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mchehab/zbar
    REF 0.23.90
    SHA512 d73d71873bec68ee021997512a9edbd223f5f5fe43c66c4dd3502224ba6009be2e5e1714766cb8e1056244673e87e0939ed0319116f61d7371b5ab79fb5e04eb
    HEAD_REF master
    PATCHES
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
        --without-xv
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
