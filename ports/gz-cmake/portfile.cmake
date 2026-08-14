string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE "${PORT}")
set(PACKAGE_NAME "${CMAKE_MATCH_1}")

ignition_modular_library(
    NAME "${PACKAGE_NAME}"
    REF "${PORT}${VERSION_MAJOR}_${VERSION}"
    VERSION "${VERSION}"
    SHA512 1419a5d6ea161f3115f15ca69eb09401c25e6ac4a0d4f4844cfde2ed4746d567c4d95643a4ad07467b720deda6cd0add5296613c27b067701b0d3afe162ffeba
    PATCHES
        find-modules.diff
        gz-find-package.diff
        gz-import-target.diff
        lock-dependencies.diff
        pkg-check-modules.diff
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
