string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE "${PORT}")
set(PACKAGE_NAME "${CMAKE_MATCH_1}")

ignition_modular_library(
    NAME "${PACKAGE_NAME}"
    REF "${PORT}${VERSION_MAJOR}_${VERSION}"
    VERSION "${VERSION}"
    SHA512 c22d942880acdd9de5613e7ebf71395d3b1bc9b70543fbcf284ccf271f593e198c9918a1c6883288d39b4c022fcb206d8b4f626fb11460d421efc2751b2e8d7c
    PATCHES
        find-modules.diff
        gz-find-package.diff
        gz-import-target.diff
        lock-dependencies.diff
        pkg-check-modules.diff
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
