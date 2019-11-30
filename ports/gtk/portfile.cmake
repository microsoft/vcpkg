
include(vcpkg_common_functions)
set(GTK_VERSION 3.24.10)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/gtk+/3.24/gtk+-${GTK_VERSION}.tar.xz"
    FILENAME "gtk+-${GTK_VERSION}.tar.xz"
    SHA512 1f7980189f522fd3646fb480b965c21801cc30b3316eb8bad8ded1efd25d3054f62160ddbe9ea241628c11b24f746024fbc3d22b17b9bd61fa6c301ab91d6498
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-Dexamples=false
		-Dtests=false
		--backend=ninja
		#-Ddemos=false # WE NEED demos, because the icons come from here, otherwise the update icon cache will fail to build!
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gtk/COPYING ${CURRENT_PACKAGES_DIR}/share/gtk/copyright)
