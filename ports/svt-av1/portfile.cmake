vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/SVT-AV1
    REF "v${VERSION}"
    SHA512 0a96e46aa602a223dcb3419232e04757b933f0da73ad22232bc8cc2e13ab5ad41c6abe16252b4a7626af3478ed85f9759b601d8ff3ef63fa545dd64a006e0d23
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
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES SvtAv1EncApp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
