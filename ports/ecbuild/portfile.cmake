set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 2c42118e9c15d7a11a5526378bd4341ddd326d1873d9edbea26fed5c3c132721642c7d79e1eb6040ae2abe38929f4cff380ab333d46463ff17e51fa44cc15d4e
    HEAD_REF develop
)

file(COPY
    "${SOURCE_PATH}/cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    PATTERN "Find*.cmake" EXCLUDE
)

file(COPY
    "${SOURCE_PATH}/share/ecbuild/check_linker"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/ecbuild-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/ecbuild-config.cmake"
    @ONLY
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/ecbuild-config-version.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/ecbuild-config-version.cmake"
    @ONLY
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/NOTICE"
)
