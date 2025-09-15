set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SRC_PATH
    REPO vsaulue/Gustave
    REF "v${VERSION}"
    SHA512 "6763eb82a62cdaf4bb79ccfc0ed594340ec6b40720ee39c4593ba36087bfbd812668d24b924cbc1a0029c76b8f34c6994f0549514b66e0f2a92f6b456f52c8c3"
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SRC_PATH}"
    OPTIONS
        "-DCMAKE_COMPILE_WARNING_AS_ERROR=OFF"
        "-DBUILD_TESTING=OFF"
        "-DGUSTAVE_BUILD_DOCS=OFF"
        "-DGUSTAVE_BUILD_TOOLS=OFF"
        "-DGUSTAVE_BUILD_TUTORIALS=OFF"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "cmake")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SRC_PATH}/LICENSE.txt")
