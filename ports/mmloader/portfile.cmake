
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
    REF 1.0.0
    SHA512 ceb2ab4b60d74209fa46d198cde6fd87a97d911abb875ac35383288a67828d0420bb38ff8d2f17dd4a3f46ba3abf554152d1246eeb05215258e8af64ac4a39de
    HEAD_REF master
)

# feature
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    shellcode BUILD_SHELLCODE_GEN
)

# config
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

# pre-clean
file(REMOVE_RECURSE ${SOURCE_PATH}/output)

# build and install
vcpkg_install_cmake(DISABLE_PARALLEL)

# remove the debug/include directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# collect license files
file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
