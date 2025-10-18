vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bytecodealliance/wasm-micro-runtime
    REF "WAMR-${VERSION}"
    SHA512 3f4ea94490ba1027473c1faf8df2d4bb6c81bd5efeccbe9d5621830dbf80b2020249263bc443c3bce86a4b2f66b1b8521e3bb831b62703bf6062f08464820943
    HEAD_REF main
    PATCHES
        fix-version-output.patch
        fix-msvc-c11.patch
        fix-preprocessor-in-assert.patch
        use-vcpkg-simde.patch
        use-vcpkg-asmjit.patch
        link-asmjit.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    #defaults
    aot WAMR_BUILD_AOT
    classic-interpreter WAMR_BUILD_INTERP
    fast-interpreter WAMR_BUILD_FAST_INTERP
    libc-builtin WAMR_BUILD_LIBC_BUILTIN
    libc-wasi WAMR_BUILD_LIBC_WASI
    ref-types WAMR_BUILD_REF_TYPES
    #other
    fast-jit WAMR_BUILD_FAST_JIT
    llvm-jit WAMR_BUILD_JIT
    multi-module WAMR_BUILD_MULTI_MODULE
    lib-pthread WAMR_BUILD_LIB_PTHREAD
    lib-wasi-threads WAMR_BUILD_LIB_WASI_THREADS
    mini-loader WAMR_BUILD_MINI_LOADER
    simd WAMR_BUILD_SIMD
)
string(REPLACE "=ON" "=1" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

# WAMR requires at least one of: classic-interpreter, fast-interpreter (requires classic), or AOT
if(NOT "classic-interpreter" IN_LIST FEATURES AND NOT "aot" IN_LIST FEATURES)
    message(STATUS "WAMR requires at least classic-interpreter or aot feature. Enabling classic-interpreter by default.")
    list(APPEND FEATURE_OPTIONS "-DWAMR_BUILD_INTERP=1")
endif()

message("FEATURE_OPTIONS:  ${FEATURE_OPTIONS}")

if("llvm-jit" IN_LIST FEATURES)
    set(LLVM_DIR "${CURRENT_INSTALLED_DIR}/share/llvm")
    list(APPEND FEATURE_OPTIONS 
        "-DLLVM_DIR=${LLVM_DIR}"
    )
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DWAMR_BUILD_PLATFORM=windows")
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
