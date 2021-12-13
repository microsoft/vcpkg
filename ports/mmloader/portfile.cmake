# fail early for unsupported triplets
vcpkg_fail_port_install(
    MESSAGE "mmLoader supports only x86/x64-windows-static triplets"
    ON_TARGET "UWP" "LINUX" "OSX" "ANDROID" "FREEBSD"
    ON_ARCH "arm" "arm64"
    ON_CRT_LINKAGE "dynamic"
    ON_LIBRARY_LINKAGE "dynamic"
)

# source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 1.0.1
    SHA512 c13e8198d4e690de593c6a0d540da531be9502a0f1c45493f3230431dfe3a57305e60cb72af5d7b34f4287587fdd1eea015c6d98198086a99b713b1da80f97b3
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
