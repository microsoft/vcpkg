set(AR_VERSION 1.1.0)
set(ARCHIVE_NAME arg_router-${AR_VERSION}.zip)

vcpkg_download_distfile(
    ARCHIVE
    URLS https://github.com/cmannett85/arg_router/releases/download/v${AR_VERSION}/${ARCHIVE_NAME}
    FILENAME ${ARCHIVE_NAME}
    SHA512 9cb75dafbdcbc02c774d5dcf17af126b7b1fc032b10cc0a2b5075897fbb80cdb0b84b631d265295210c3a7bdae682065f417d8ca70937118de97f14ed46bd31b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(
    COPY "${SOURCE_PATH}/include/arg_router/arg_router-config.cmake"
         "${SOURCE_PATH}/include/arg_router/arg_router-config-version.cmake"
         "${SOURCE_PATH}/include/arg_router/README.md"
         "${SOURCE_PATH}/include/arg_router/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/arg_router"
)
file(
    COPY "${SOURCE_PATH}/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
)
file(
    COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
    FILE_LIST "${CURRENT_PACKAGES_DIR}/share/arg_router/LICENSE"
)

