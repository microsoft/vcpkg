vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/lexxmark/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip"
    FILENAME "win_flex_bison-2.5.25.zip"
    SHA512 2a829eb05003178c89f891dd0a67add360c112e74821ff28e38feb61dac5b66e9d3d5636ff9eef055616aaf282ee8d6be9f14c6ae4577f60bdcec96cec9f364e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${SOURCE_PATH}/FlexLexer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/winflexbison)
file(COPY ${SOURCE_PATH}/win_bison.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/winflexbison)
file(COPY ${SOURCE_PATH}/win_flex.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/winflexbison)
file(COPY ${SOURCE_PATH}/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/winflexbison)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/winflexbison RENAME copyright)

