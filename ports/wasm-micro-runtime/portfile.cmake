vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bytecodealliance/wasm-micro-runtime
    REF "WAMR-${VERSION}"
    SHA512 3f4ea94490ba1027473c1faf8df2d4bb6c81bd5efeccbe9d5621830dbf80b2020249263bc443c3bce86a4b2f66b1b8521e3bb831b62703bf6062f08464820943
    HEAD_REF main
    PATCHES
        fix-version-output.patch
        fix-msvc-c11.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    aot WAMR_BUILD_AOT
    classic-interpreter WAMR_BUILD_INTERP
    fast-interpreter WAMR_BUILD_FAST_INTERP
    llvm-jit WAMR_BUILD_JIT
    fast-jit WAMR_BUILD_FAST_JIT
    libc-builtin WAMR_BUILD_LIBC_BUILTIN
    libc-wasi WAMR_BUILD_LIBC_WASI
    multi-module WAMR_BUILD_MULTI_MODULE
    lib-pthread WAMR_BUILD_LIB_PTHREAD
    lib-wasi-threads WAMR_BUILD_LIB_WASI_THREADS
    simd WAMR_BUILD_SIMD
    ref-types WAMR_BUILD_REF_TYPES
    mini-loader WAMR_BUILD_MINI_LOADER
    copy-call-stack WAMR_BUILD_COPY_CALL_STACK
)
string(REPLACE "=ON" "=1" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

message("FEATURE_OPTIONS:  ${FEATURE_OPTIONS}")

if (VCPKG_TARGET_IS_WINDOWS)
    # Fast JIT is not supported on Windows (per WAMR runtime_lib.cmake)
    # Override to disable it regardless of feature flags
    message(STATUS "Disabling WAMR Fast JIT on Windows (not supported by WAMR)")
    string(REPLACE "-DWAMR_BUILD_FAST_JIT=1" "-DWAMR_BUILD_FAST_JIT=0" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
    # Set platform explicitly
    list(APPEND FEATURE_OPTIONS "-DWAMR_BUILD_PLATFORM=windows")
    
    # Disable hardware bound check on Windows to avoid Zydis dependency
    # This is a workaround since Zydis integration in WAMR uses FetchContent
    list(APPEND FEATURE_OPTIONS "-DWAMR_DISABLE_HW_BOUND_CHECK=1")
endif ()
message("FEATURE_OPTIONS:  ${FEATURE_OPTIONS}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME iwasm CONFIG_PATH lib/cmake/iwasm)

file(INSTALL
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    TYPE FILE
    FILES "${CMAKE_CURRENT_LIST_DIR}/usage"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
