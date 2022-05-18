# source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 1.0.1
    SHA512 a41749e1b62d5549b821429a03e456a0cb41fbc1ea3fe5e8067f80994fb4645c3145dd1e2a3ccaed13b091ec24338d4e542849628d346f26d2275b0cbff8f4c6
    HEAD_REF master
)

# feature
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        shellcode BUILD_SHELLCODE_GEN
)

# config
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

# pre-clean
file(REMOVE_RECURSE "${SOURCE_PATH}/output")

# build and install
vcpkg_install_cmake(DISABLE_PARALLEL)

# remove the debug/include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# collect license files
file(INSTALL "${SOURCE_PATH}/License" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
