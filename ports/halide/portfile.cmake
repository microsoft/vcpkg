vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Halide distributes some loadable modules that belong in lib on all platforms.
# CMake defaults module DLLs into the lib folder, which is incompatible with
# vcpkg’s current policy. This sidesteps that issue, a bit bluntly.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF fa9d6e1fa40c449883a7d64ca1fbc58ec94259af  # refs/tags/v10.0.0
    SHA512 e6da0b0798d921443a946159a67db8631e423d5bdd738c59ac872c1113cd40223f02f2bc63b3e7d6001eebb4c6b85a9229030f17f6082ae4e7c489d5612b966c
    HEAD_REF release/10.x
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
        -DWITH_APPS=NO
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
