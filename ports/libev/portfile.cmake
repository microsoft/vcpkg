vcpkg_download_distfile(ARCHIVE
    URLS "http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz"
    FILENAME "libev-4.33.tar.gz"
    SHA512 c662a65360115e0b2598e3e8824cf7b33360c43a96ac9233f6b6ea2873a10102551773cad0e89e738541e75af9fd4f3e3c11cd2f251c5703aa24f193128b896b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES "0000-event-fix-undefined-struct-timeval.patch"
)

set(LIBEV_LINK_FLAGS "")

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND LIBEV_LINK_FLAGS "LDFLAGS=-no-undefined -lws2_32 \$LDFLAGS")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${LIBEV_LINK_FLAGS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include.tmp")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include.tmp" "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libev-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
