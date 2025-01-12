set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(PACKAGE_NAME tools)

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 0dc78d30876f2091c5a545feb70e769d65967c6f77bca7bc17aec62a5069601657fd4bf03f7a913ef5ad8bb58ca8aba4b2b911c6d4de4d46f827edb609acd61c
                         PATCHES
                        )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
