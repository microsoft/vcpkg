set(PACKAGE_NAME cmake)

ignition_modular_library(
    NAME ${PACKAGE_NAME}
    REF ${PORT}_${VERSION}
    VERSION ${VERSION}
    SHA512 e348e49a19fa1db711df8f0d2d1426c72487f035a75b14cd4e37fa49ac6dad61e76f4488af07d589100d05411e3a0a92779e99bb024cb15a4aa91bb51f4b2f88
    PATCHES
        dependencies.patch
)

file(COPY "${CURRENT_PORT_DIR}/vcpkg" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cmake/gz-cmake3/cmake3")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
