vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF v0.5.4
    SHA512 16c7c39ca59128fe6489ec70b0d840d48cc44e57fe0d7d2dc864443cf8be288ceaf32e28246f6ac2dda495662d7a38d1e6ddf49172a73aac55445ecea95a29a8
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    x11 INFOWARE_USE_X11
    d3d INFOWARE_USE_D3D
    opencl INFOWARE_USE_OPENCL
    opengl INFOWARE_USE_OPENGL
)

# git must be injected, because vcpkg isolates the build
# from the environment entirely to have reproducible builds
vcpkg_find_acquire_program(GIT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINFOWARE_EXAMPLES=OFF
        -DINFOWARE_TESTS=OFF
        -DGIT_EXECUTABLE=${GIT}
        -DGIT_FOUND=true
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
