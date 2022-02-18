if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/atkmm/2.36/atkmm-2.36.0.tar.xz"
    FILENAME "atkmm-2.36.0.tar.xz"
    SHA512 8527dfa50191919a7dcf6db6699767352cb0dac800d834ee39ed21694eee3136a41a7532d600b8b3c0fcea52da6129b623e8e61ada728d806aa61fdc8dc8dedf
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS 
        -Dbuild-documentation=false
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
        -Dmsvc14x-parallel-installable=false) # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
