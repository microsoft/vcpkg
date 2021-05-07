vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/infoware
    REF v0.6.0
    SHA512 38be9e375508c7fdee4be3540d80c95bf14dbef68c7880d3dc98de3128b43680c18ceb09fb0da33b6d31064d8cdbf0672671d6b4be4f0a4208a0b99d0224bd2e
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
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
