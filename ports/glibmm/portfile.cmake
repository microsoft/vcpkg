# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/glibmm/2.52/glibmm-2.52.1.tar.xz"
    FILENAME "glibmm-2.52.1.tar.xz"
    SHA512 702158762cb28972b315ab98dc00a62e532bda08b6e76dc2a2556e8cb381c2021290891887a4af2fbff5a62bab4d50581be73037dc8e0dc47d5febd6cbeb7bda
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        glibmm-api-variant.patch
        fix-define-glibmmconfig.patch
        fix-thread.h.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_HEADER=${CMAKE_CURRENT_LIST_DIR}/msvc_recommended_pragmas.h
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright and readme
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME readme.txt)