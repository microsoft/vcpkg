vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF 6569a831f2ee7f1a2e3d809c36fb92514d710c44
    SHA512 48c5a000719835d5119fd2c50b026c9125aeab4021641d2891b89ac8da3ec7c02c5f86837779dcae6e6bc8d929f6a182045bebe7e0990e33844b4d52f21df519
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        target-aarch64 TARGET_AARCH64
        target-amdgpu TARGET_AMDGPU
        target-arm TARGET_ARM
        target-d3d12compute TARGET_D3D12COMPUTE
        target-opengl-compute TARGET_OPENGLCOMPUTE
        target-hexagon TARGET_HEXAGON
        target-metal TARGET_METAL
        target-nvptx TARGET_NVPTX
        target-opencl TARGET_OPENCL
        target-powerpc TARGET_POWERPC
        target-riscv TARGET_RISCV
        target-webassembly TARGET_WEBASSEMBLY
        target-x86 TARGET_X86
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_WABT=OFF
        -DWITH_V8=OFF
        -DWITH_DOCS=OFF
        -DWITH_PYTHON_BINDINGS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TUTORIALS=OFF
        -DWITH_UTILS=OFF
        -DWITH_SERIALIZATION=OFF # Disable experimental serializer
        -DCMAKE_INSTALL_LIBDIR=bin
        "-DCMAKE_INSTALL_DATADIR=share/${PORT}"
        "-DHalide_INSTALL_CMAKEDIR=share/${PORT}"
        -DHalide_INSTALL_HELPERSDIR=share/HalideHelpers
        -DHalide_INSTALL_PLUGINDIR=bin
        -DCMAKE_DISABLE_FIND_PACKAGE_PNG=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=JPEG
)

# ADD_BIN_TO_PATH needed to compile autoschedulers, 
# which use Halide.dll (and deps) during the build.
vcpkg_cmake_install(ADD_BIN_TO_PATH)

# Release mode MODULE targets in CMake don't get PDBs.
# Exclude those to avoid warning with default globs.
vcpkg_copy_pdbs(
    BUILD_PATHS
        "${CURRENT_PACKAGES_DIR}/bin/Halide.dll" 
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
)

vcpkg_cmake_config_fixup()
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideHelpers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
