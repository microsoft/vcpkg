vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/SVT-AV1
    REF "v${VERSION}"
    SHA512 4301e923965e3bff30a0fd2f74ae023d19260f91c2361d48ea7bc1718f501dcca73fa17cb8795b23392ca1bfbe1f4d55edcbb5ce06a2fa9e41da36c5166f527d
    PATCHES
        android-llvm.diff
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(${NASM_EXE_PATH})
    set(DISABLE_SIMD OFF)
else()
    set(DISABLE_SIMD ON)
endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        tool   BUILD_APPS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DBUILD_SHARED_LIBS=${ENABLE_SHARED}
        -DCOMPILE_C_ONLY=${DISABLE_SIMD}
        -DREPRODUCIBLE_BUILDS=ON
        -DEXCLUDE_HASH=OFF
        -DBUILD_TESTING=OFF
        -DSVT_AV1_LTO=OFF
    OPTIONS_RELEASE
        -DCMAKE_OUTPUT_DIRECTORY="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Bin/Release"
    OPTIONS_DEBUG
        -DCMAKE_OUTPUT_DIRECTORY="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Bin/Debug"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES SvtAv1EncApp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
