vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF 50cb0982aceb32c8eb57aa6bc5011aced2c379df
    SHA512 fe8182998a9e9dbed3dc3985a1161da11b340562628a71da8840aa4d4c56382ddc3ddef3d094e5d9c7c06481a2076dcff7fdb561bd169dd9d1849da4b4c6a064
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        x11 INFOWARE_USE_X11
        d3d INFOWARE_USE_D3D
        opencl INFOWARE_USE_OPENCL
        opengl INFOWARE_USE_OPENGL
)

# git must be injected, because vcpkg isolates the build
# from the environment entirely to have reproducible builds
vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINFOWARE_EXAMPLES=OFF
        -DINFOWARE_TESTS=OFF
        -DGIT_EXECUTABLE=${GIT}
        -DGIT_FOUND=true
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
