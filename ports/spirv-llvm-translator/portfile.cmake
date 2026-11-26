vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-LLVM-Translator
    REF "v${VERSION}"
    SHA512 fff2224f63926819e29d5f2daa54015b486497f131ecf4b563cfde75a594812a5c395b67971022be13de42d7429db1fc747c725c15978894baa3a62013d98777
    HEAD_REF main
    PATCHES
        spirv-tools-dis.patch
        cmake-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spirv-tools LLVM_SPIRV_ENABLE_LIBSPIRV_DIS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLLVM_SPIRV_BUILD_EXTERNAL=ON
        -DLLVM_SPIRV_INCLUDE_TESTS=OFF
        "-DLLVMSPIRV_PACKAGE_VERSION=${VERSION}"
        "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=${CURRENT_INSTALLED_DIR}"
        -DCCACHE_ALLOWED=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-spirv-llvm-translator CONFIG_PATH lib/cmake/unofficial-spirv-llvm-translator)

vcpkg_copy_tools(TOOL_NAMES llvm-spirv AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.TXT"
    "${SOURCE_PATH}/lib/SPIRV/LLVMBitreverse.h"
    "${SOURCE_PATH}/lib/SPIRV/SPIRVLowerLLVMIntrinsic.cpp"
    "${SOURCE_PATH}/lib/SPIRV/libSPIRV/SPIRVFnVar.cpp"
    "${SOURCE_PATH}/lib/SPIRV/libSPIRV/SPIRVLLVMUtil.h"
)
