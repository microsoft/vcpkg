set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/kineto
    REF 094d3c1d072362d0a919a77299459eee94f97931
    SHA512 1f77eb52c17a4761f1f9772de196ba3400c5a9edacc2c3e558c2aafb685f3b4c7bf9402ffe5933cc5f87672e24329a730d5ad3522f7c9b13b0d1e15407509f14
    HEAD_REF main
)

# Install headers flat (code uses #include <libkineto.h> directly)
file(INSTALL "${SOURCE_PATH}/libkineto/include/"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Avoid taking extremely common name "Config.h" which breaks many projects that assume it is their
# internal config.h header.
file(RENAME "${CURRENT_PACKAGES_DIR}/include/Config.h" "${CURRENT_PACKAGES_DIR}/include/KinetoConfig.h")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/IActivityProfiler.h" "#include \"Config.h\"" "#include \"KinetoConfig.h\"")

# Provide cmake config
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-kineto-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-kineto/unofficial-kineto-config.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
