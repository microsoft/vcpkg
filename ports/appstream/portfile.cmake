vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ximion/appstream
    REF "v${VERSION}"
    SHA512 2e673af579107603458cf09086ffc8cb488aa4ab24d248c7774b8b6d8e690aac49b2c5ddda56533b179e017f54fa4598ebae5bb7cb3073b3f03149700a7db9ac
    HEAD_REF main
    PATCHES
      remove-uneeded-directories.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dsystemd=false
      -Dapidocs=false
      -Dinstall-docs=false
      -Dstemming=false
      -Dsvg-support=false
      -Dgir=false
    ADDITIONAL_BINARIES
       gperf='${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${HOST_EXECUTABLE_SUFFIX}'
       glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
       glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
