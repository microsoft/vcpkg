set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 f6a390660ac8956558ff5df2652d91fab3e800c65c351023844e2b5d81785013b1cb3dadd8a0c85a696ff2e5acd7c36e12e4ff3843e0927f4be19fea87298fd4
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
