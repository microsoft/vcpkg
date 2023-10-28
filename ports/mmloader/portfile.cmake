vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 1.0.1
    SHA512 a41749e1b62d5549b821429a03e456a0cb41fbc1ea3fe5e8067f80994fb4645c3145dd1e2a3ccaed13b091ec24338d4e542849628d346f26d2275b0cbff8f4c6
    HEAD_REF master
    PATCHES
        fix-platform-name.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        shellcode BUILD_SHELLCODE_GEN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(DISABLE_PARALLEL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
