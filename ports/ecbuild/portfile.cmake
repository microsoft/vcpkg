set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 937f3777acdd1890069e9d7b3d51e9bb24ce26e7180433bd74be4790772e393af98907fbeae34dbec9f2f2410acb35211e93c63807ed6c57539c192c7d3e4180
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
    "${SOURCE_PATH}/cmake/contrib/GetGitRevisionDescription.cmake"
)
