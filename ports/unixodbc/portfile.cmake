vcpkg_fail_port_install(ON_TARGET "UWP" "Windows")

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO lurcher/unixODBC
        REF 2.3.7
        SHA512 94e95730304990fc5ed4f76ebfb283d8327a59a3329badaba752a502a2d705549013fd95f0c92704828c301eae54081c8704acffb412fd1e1a71f4722314cec0
        HEAD_REF master
)

vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        COPY_SOURCE
)

vcpkg_install_make()

vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif ()

file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/include"
     "${CURRENT_PACKAGES_DIR}/debug/share"
     "${CURRENT_PACKAGES_DIR}/debug/etc"
     "${CURRENT_PACKAGES_DIR}/etc"
     "${CURRENT_PACKAGES_DIR}/share/man"
     )
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/unixodbcConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
