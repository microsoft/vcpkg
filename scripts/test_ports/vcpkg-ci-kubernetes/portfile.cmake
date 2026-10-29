set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF v0.14.0
    SHA512 8324049f030201e9a031556a799defcbc90fe41bc7b40e2997ed0c706f97660af39b84d679065e83adce85b66c832d406468a9c543367b64c5b702fc5896ee07
    HEAD_REF master
    PATCHES
        standalone.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_FILE=${SOURCE_PATH}/examples/generic/main.c"
)
vcpkg_cmake_build()
