set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 3092a0d9352670b869e0bc00bddc53eb735851a7cdffe5c04382859bc346e6c18f61f8e4e7ad71a4dc3aa982fb09ff8158f1f44e1f21a1bbb5a6862a3545a8eb
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
