set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF 1.25.4
    SHA512 76b0cd9ea2ea203ae37ce17dd2de8fceb13d0ff2fc24a31483306c6a6ecd4851d2ecb81e177c3ebc1e4eea7404697b4aeba451883dd40b21f10bb3eb101da411
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
)
vcpkg_cmake_build()
