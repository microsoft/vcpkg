set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}${VERSION_MAJOR}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 d74eb686c05c62dea5303e629136a187aa09db67305cdc46577e8ff6dd420b70b074d25474669c9d3f1286d141d1e30cf9b4b32b726f0e6d2bae4dabc298160b
                         PATCHES
                        )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
