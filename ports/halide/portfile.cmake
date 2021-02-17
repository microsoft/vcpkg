vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Halide distributes some loadable modules that belong in lib on all platforms.
# CMake defaults module DLLs into the lib folder, which is incompatible with
# vcpkg’s current policy. This sidesteps that issue, a bit bluntly.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF 405cd5fe1c8bcc40f528174cac8291f8be83753c
    SHA512 69a8e8e9fde4d9c759170ea7ff26fd14b9dcf773d2f7b60b9eb2fb7ed3234e7d088e09a6b74365704575c9b4515a66ef810a6aee7656d28e905827bbdd6b1467
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
