string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
    NAME ${PACKAGE_NAME}
    REF ${PORT}${VERSION_MAJOR}_${VERSION}
    VERSION ${VERSION}
    SHA512 d761aba28fc79af6bbb021215367e48e1b7449885d0410a0cabd09674a59b17132810ebb796fe0e1ddefc1510aba832fb192cc908156d8eae15e35c1afe464c7
    PATCHES
        dependencies.patch
        ffempg_depends_interface.patch
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
