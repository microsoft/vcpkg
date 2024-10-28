set(PACKAGE_NAME cmake)

ignition_modular_library(
    NAME ${PACKAGE_NAME}
    REF ${PORT}_${VERSION}
    VERSION ${VERSION}
    SHA512 30cf5aa69674bdc1a99762fc45d134b99da5e2faf846749392697ae41463a5304a43022bb0c2ca1b373af4171135d686fdd736573fe6e1cc26dc2cecc8333e69
    PATCHES
        dependencies.patch
)

file(COPY "${CURRENT_PORT_DIR}/vcpkg" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cmake/gz-cmake3/cmake3")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
