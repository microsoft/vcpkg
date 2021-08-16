vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF 5dabcaa9effca1067f907f6c8ea212f3d2b1d99a  # v12.0.1
    SHA512 5ab44703850885561337e23d8b538a5adfe1611e24e8daa4a1313756b4f9dfeb54e89bf8400d46a3340c00234402681b4f44ba3ed5322027fd6cb5dfbd525acd
    HEAD_REF release/12.x
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        target-aarch64 TARGET_AARCH64
        target-amdgpu TARGET_AMDGPU
        target-arm TARGET_ARM
        target-d3d12compute TARGET_D3D12COMPUTE
        target-hexagon TARGET_HEXAGON
        target-metal TARGET_METAL
        target-mips TARGET_MIPS
        target-nvptx TARGET_NVPTX
        target-opencl TARGET_OPENCL
        target-powerpc TARGET_POWERPC
        target-riscv TARGET_RISCV
        target-x86 TARGET_X86
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_DOCS=NO
        -DWITH_PYTHON_BINDINGS=NO
        -DWITH_TESTS=NO
        -DWITH_TUTORIALS=NO
        -DWITH_UTILS=NO
        -DCMAKE_INSTALL_LIBDIR=bin
        -DCMAKE_INSTALL_DATADIR=share/${PORT}
        -DHalide_INSTALL_CMAKEDIR=share/${PORT}
        -DHalide_INSTALL_HELPERSDIR=share/HalideHelpers
        -DHalide_INSTALL_PLUGINDIR=bin
)

# ADD_BIN_TO_PATH needed to compile autoschedulers, 
# which use Halide.dll (and deps) during the build.
vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_tools(
    TOOL_NAMES
        featurization_to_sample
        get_host_target
        retrain_cost_model
        weightsdir_to_weightsfile
    AUTO_CLEAN
)

# Release mode MODULE targets in CMake don't get PDBs.
# Exclude those to avoid warning with default globs.
vcpkg_copy_pdbs(
    BUILD_PATHS
        "${CURRENT_PACKAGES_DIR}/bin/Halide.dll" 
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
)

vcpkg_cmake_config_fixup()
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideHelpers)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/tutorial)

file(GLOB readmes "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.md")
file(REMOVE ${readmes})

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
