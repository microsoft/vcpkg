set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(PACKAGE_NAME tools)

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 1b89048d09821db5a902758e133e6e73052941fdb9838daed5540267ef9203512170a031cf94a29564cac15133489609e83e965f31f930f7d7be477a8d9c2667
                         PATCHES
                        )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
