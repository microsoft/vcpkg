vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/sequence
    # REF v${VERSION}
    REF 196e08c0534ae31ae735dab1d32e22f4dc7bab76
    SHA512 d3149d153a46dfb40e605fb51ee24a51c4c0f07d64d31e5da1d7d190925f59d6a760307284e440a79cfa23c7d2f52b3bf42ea2ce09d5fd07e34c904368ce53e7
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp FL_SEQUENCE_USE_OPENMP
        cuda   FL_SEQUENCE_USE_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFL_SEQUENCE_BUILD_TESTS=OFF
        -DFL_SEQUENCE_BUILD_STANDALONE=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
    OPTIONS_RELEASE
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
