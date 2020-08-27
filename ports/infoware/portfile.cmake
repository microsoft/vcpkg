vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF v0.5.5
    SHA512 06aea2c3a51df30cfc220eafb603620c3cf5f00b0d5935486ac46c6c2333972910af2b53fc1e2187b5fce0aa9650323a0dff526d768ff54888bfc549a8173903
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
