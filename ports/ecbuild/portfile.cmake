set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 2ab79b8c50fb919fbcd0f13fb40e00bba790c192a452beb93fc6092d38a7fd2413e2ab3112254efb3f23d572f324e072035436d6cb1fbae2ca7ea84bb280ca63
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
