vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Halide distributes some loadable modules that belong in lib on all platforms.
# CMake defaults module DLLs into the lib folder, which is incompatible with
# vcpkg’s current policy. This sidesteps that issue, a bit bluntly.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    # TODO: do not merge without updating to final version
    REF 0abe228fd9f187176c3af0726a1dc663e76242a8
    SHA512 069058c40b40eea8413887b66aee35b3555707a12349869472562d3bf6f55bcf37e16bc4f4ce9a9de301f16ad020387b8ab06d559cc590d4471988eda6aeb8a1
    HEAD_REF backports/11.x
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
