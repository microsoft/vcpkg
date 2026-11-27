vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/SVT-AV1
    REF "v${VERSION}"
    SHA512 1d131943fef2bea9bb7a193aae8d10e5225cb8df36a880633226105f88ef735a48c29a0d78d578933b9f0bca2f41a16023ce71adf46c4f0e587f7123d60f074a
    PATCHES
        no-force-llvm.diff
        no-safestringlib.diff
        unvendor-fastfeat.diff
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/aom/inc/")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/aom_dsp/")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/fastfeat/")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/googletest/")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/safestringlib/")

if (VCPKG_TARGET_ARCHITECTURE MATCHES "^(x86|x64)")
    vcpkg_find_acquire_program(NASM)
    set(SIMD_OPTIONS -DCOMPILE_C_ONLY=OFF "-DCMAKE_ASM_NASM_COMPILER=${NASM}")
else()
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(arm64|arm64ec)$" AND NOT VCPKG_TARGET_IS_WINDOWS)
        set(SIMD_OPTIONS -DCOMPILE_C_ONLY=OFF)
    else()
        set(SIMD_OPTIONS -DCOMPILE_C_ONLY=ON)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${SIMD_OPTIONS}
        -DBUILD_APPS=OFF
        -DREPRODUCIBLE_BUILDS=ON
        -DEXCLUDE_HASH=OFF
        -DBUILD_TESTING=OFF
        -DSVT_AV1_LTO=OFF
        "-DFASTFEAT_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/"
        OPTIONS_RELEASE
        "-DFASTFEAT_LIB_DIR=${CURRENT_INSTALLED_DIR}/lib/"
        "-DCMAKE_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Bin/Release"
    OPTIONS_DEBUG
        "-DFASTFEAT_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib/"
        "-DCMAKE_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Bin/Debug"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SVT-AV1 CONFIG_PATH lib/cmake/SVT-AV1)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES SvtAv1EncApp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md" "${SOURCE_PATH}/PATENTS.md")
