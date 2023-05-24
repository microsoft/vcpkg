vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(HALIDE_VERSION_TAG v${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF ${HALIDE_VERSION_TAG}
    SHA512 918cd0a7e69e4414b98f17c5ec5cdb543ce3ae68ed07c9a80b7c0378c247a4a4fde62ade79b402e9ffcfce30c066a3fa662ea46c3a2a5b93eb5ec4e05b3fd808
    HEAD_REF release/15.x
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
        target-mips TARGET_MIPS
        target-nvptx TARGET_NVPTX
        target-opencl TARGET_OPENCL
        target-powerpc TARGET_POWERPC
        target-riscv TARGET_RISCV
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

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
