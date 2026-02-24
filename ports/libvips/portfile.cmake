# ./vcpkg install "libvips[exif,fontconfig,jpeg,lcms,pangocairo,rsvg,zlib]" --recurse

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libvips/libvips
    REF v${VERSION}
    SHA512 f8acf184efe1855ad3e65d7393a57dff219b812cc5fb368e8020e8cf12f7a12dec7c7ce954669a3055ad7792eb8905ef2e9c72b8d6b8ff597720403073b65468
    HEAD_REF master
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")
#vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
        -Dintrospection=disabled
	#	-Dfuzzing_engine=none
	#ADDITIONAL_BINARIES
    #    glib-genmarshal='${CURRENT_INSTALLED_DIR}/tools/glib/glib-genmarshal'
    #    glib-mkenums='${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums'
	#	"g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson()

#vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
