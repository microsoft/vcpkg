set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF 1.26.10
    SHA512 c0f802fd2b181587df1748a8db7163bbcd3951b943d1321afcff56fccb515dfe99061288bc691323d0854305a1d4205c99457954b10439adb122975429cbce72
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
)
vcpkg_cmake_build()
