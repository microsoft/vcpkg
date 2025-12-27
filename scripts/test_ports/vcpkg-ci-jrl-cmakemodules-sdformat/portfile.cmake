set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        -Djrl-cmakemodules_DIR=${jrl-cmakemodules_DIR}
)

vcpkg_cmake_build()
