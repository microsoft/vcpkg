vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Halide distributes some loadable modules that belong in lib on all platforms.
# CMake defaults module DLLs into the lib folder, which is incompatible with
# vcpkg’s current policy. This sidesteps that issue, a bit bluntly.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF 0a1a77e47183888dc343eb29d1e1076e868a0ac4  # refs/tags/v11.0.0
    SHA512 893781a2277a75fce5a4025461a4f5236a7cce81661e873f71cf3afffd4ccb9e8739f4b94b7e513f8e2451a4a3aebad38c6364cf0cc1a9bd52314b2cc82e7011
    HEAD_REF release/11.x
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    target-aarch64 TARGET_AARCH64
    target-amdgpu TARGET_AMDGPU
    target-arm TARGET_ARM
    target-d3d12compute TARGET_D3D12COMPUTE
    target-hexagon TARGET_HEXAGON
    target-metal TARGET_METAL
    target-mips TARGET_MIPS
    target-nvptx TARGET_NVPTX
    target-opencl TARGET_OPENCL
    target-opengl TARGET_OPENGL
    target-powerpc TARGET_POWERPC
    target-riscv TARGET_RISCV
    target-x86 TARGET_X86
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_DOCS=NO
        -DWITH_PYTHON_BINDINGS=NO
        -DWITH_TESTS=NO
        -DWITH_TUTORIALS=NO
        -DWITH_UTILS=NO
        -DCMAKE_INSTALL_LIBDIR=bin
        -DCMAKE_INSTALL_DATADIR=share/${PORT}
        -DHALIDE_INSTALL_CMAKEDIR=share/${PORT}
)

vcpkg_install_cmake()

vcpkg_copy_tools(
    TOOL_NAMES
        featurization_to_sample
        get_host_target
        retrain_cost_model
        weightsdir_to_weightsfile
    AUTO_CLEAN
)

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/tutorial)

file(GLOB readmes "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.md")
file(REMOVE ${readmes})

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
