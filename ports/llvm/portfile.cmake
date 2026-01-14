# Suppress warning: There should be no installed empty directories
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# [BOLT] Allow to compile with MSVC (#151189)
vcpkg_download_distfile(
    PATCH1_FILE
    URLS https://github.com/llvm/llvm-project/commit/497d17737518d417f6411d46aef1334f642ccd81.patch?full_index=1
    SHA512 7bf4d4ee8f72fea5b8094320d1f3a71063ec19fe1b552424182c4140055bf6aacfa9ff64b0bcab0a8d6739e4b6249641f58d19fb6b35e1ada67b66b53776dc1a
    FILENAME 497d17737518d417f6411d46aef1334f642ccd81.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO llvm/llvm-project
    REF "llvmorg-${VERSION}"
    SHA512 86366a476d29db48460bd75ac58e6b8af97f670dcd1a1f188bb900fb4b3d2cf66e56712ae0f66e4bd8399f1eba837a26f838b4e46bb2e95357a9c0d768668379
    HEAD_REF main
    PATCHES
        0001-fix-install-package-dir.patch
        0002-fix-tools-install-dir.patch
        0003-fix-llvm-config.patch
        0004-disable-libomp-aliases.patch
        0005-fix-runtimes.patch
        0006-create-destination-mlir-directory.patch
        "${PATCH1_FILE}"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools LLVM_BUILD_TOOLS
        tools LLVM_INCLUDE_TOOLS
        utils LLVM_BUILD_UTILS
        utils LLVM_INCLUDE_UTILS
        utils LLVM_INSTALL_UTILS
        enable-assertions LLVM_ENABLE_ASSERTIONS
        enable-rtti LLVM_ENABLE_RTTI
        enable-ffi LLVM_ENABLE_FFI
        enable-eh LLVM_ENABLE_EH
        enable-bindings LLVM_ENABLE_BINDINGS
        export-symbols LLVM_EXPORT_SYMBOLS_FOR_PLUGINS
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

# LLVM generates CMake error due to Visual Studio version 16.4 is known to miscompile part of LLVM.
# LLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON disables this error.
# See https://developercommunity.visualstudio.com/content/problem/845933/miscompile-boolean-condition-deduced-to-be-always.html
# and thread "[llvm-dev] Longstanding failing tests - clang-tidy, MachO, Polly" on llvm-dev Jan 21-23 2020.
if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND VCPKG_DETECTED_MSVC_VERSION LESS "1925")
    list(APPEND FEATURE_OPTIONS
        -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON
    )
endif()

# Force enable or disable external libraries
set(llvm_external_libraries
    zlib
    libxml2
    zstd
)
foreach(external_library IN LISTS llvm_external_libraries)
    string(TOLOWER "enable-${external_library}" feature_name)
    string(TOUPPER "LLVM_ENABLE_${external_library}" define_name)
    if(feature_name IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS
            -D${define_name}=FORCE_ON
        )
    else()
        list(APPEND FEATURE_OPTIONS
            -D${define_name}=OFF
        )
    endif()
endforeach()

# LLVM_ABI_BREAKING_CHECKS can be WITH_ASSERTS (default), FORCE_ON or FORCE_OFF.
# By default in LLVM, abi-breaking checks are enabled if assertions are enabled.
# however, this breaks linking with the debug versions, since the option is
# baked into the header files; thus, we always turn off LLVM_ABI_BREAKING_CHECKS
# unless the user asks for it
if("enable-abi-breaking-checks" IN_LIST FEATURES)
    # Force enable abi-breaking checks.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_ON
    )
else()
    # Force disable abi-breaking checks.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF
    )
endif()

# All projects: bolt;clang;clang-tools-extra;lld;lldb;mlir;polly
# Extra projects: flang
set(LLVM_ENABLE_PROJECTS)
if("bolt" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "bolt")
    list(APPEND FEATURE_OPTIONS
        -DBOLT_TOOLS_INSTALL_DIR:PATH=tools/llvm
    )
endif()
if("clang" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang")
    vcpkg_check_features(
        OUT_FEATURE_OPTIONS CLANG_FEATURE_OPTIONS
        FEATURES
            clang-enable-cir CLANG_ENABLE_CIR
            clang-enable-static-analyzer CLANG_ENABLE_STATIC_ANALYZER
    )
    string(REGEX MATCH "^[0-9]+" CLANG_VERSION_MAJOR ${VERSION})
    list(APPEND CLANG_FEATURE_OPTIONS
        -DCLANG_INSTALL_PACKAGE_DIR:PATH=share/clang
        -DCLANG_TOOLS_INSTALL_DIR:PATH=tools/llvm
        # 1) LLVM/Clang tools are relocated from ./bin/ to ./tools/llvm/ (CLANG_TOOLS_INSTALL_DIR=tools/llvm)
        # 2) Clang resource files should be relocated from lib/clang/<major_version> to ../tools/llvm/lib/clang/<major_version>
        -DCLANG_RESOURCE_DIR=lib/clang/${CLANG_VERSION_MAJOR}
    )
endif()
if("clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang-tools-extra")
endif()
if("flang" IN_LIST FEATURES)
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        message(FATAL_ERROR "Building Flang with MSVC is not supported on x86. Disable it until issues are fixed.")
    endif()
    list(APPEND LLVM_ENABLE_PROJECTS "flang")
    list(APPEND FEATURE_OPTIONS
        -DFLANG_INSTALL_PACKAGE_DIR:PATH=share/flang
        -DFLANG_TOOLS_INSTALL_DIR:PATH=tools/llvm
    )
    list(APPEND FEATURE_OPTIONS
        # Flang requires C++17
        -DCMAKE_CXX_STANDARD=17
    )
endif()
if("lld" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "lld")
    list(APPEND FEATURE_OPTIONS
        -DLLD_INSTALL_PACKAGE_DIR:PATH=share/lld
        -DLLD_TOOLS_INSTALL_DIR:PATH=tools/llvm
    )
endif()
if("lldb" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "lldb")
    list(APPEND FEATURE_OPTIONS
        -DLLDB_ENABLE_CURSES=OFF
    )
endif()
if("mlir" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "mlir")
    list(APPEND FEATURE_OPTIONS
        -DMLIR_INSTALL_PACKAGE_DIR:PATH=share/mlir
        -DMLIR_TOOLS_INSTALL_DIR:PATH=tools/llvm
        -DMLIR_INSTALL_AGGREGATE_OBJECTS=OFF # Disables installation of object files in lib/objects-{CMAKE_BUILD_TYPE}.
    )
    if("enable-mlir-python-bindings" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS
            -DMLIR_ENABLE_BINDINGS_PYTHON=ON
            "-Dpybind11_DIR=${CURRENT_INSTALLED_DIR}/share/pybind11"
        )
    endif()
endif()
if("polly" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "polly")
    list(APPEND FEATURE_OPTIONS
        -DPOLLY_INSTALL_PACKAGE_DIR:PATH=share/polly
    )
endif()

# Supported runtimes: libc;libclc;libcxx;libcxxabi;libunwind;compiler-rt;openmp;llvm-libgcc;offload;flang-rt
set(LLVM_ENABLE_RUNTIMES)
if("libc" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "libc")
endif()
if("libclc" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "libclc")
endif()
if("libcxx" IN_LIST FEATURES)
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND VCPKG_DETECTED_MSVC_VERSION LESS "1914")
        # libcxx supports being built with clang-cl, but not with MSVC’s cl.exe, as cl doesn’t support the #include_next extension.
        # Furthermore, VS 2017 or newer (19.14) is required.
        # More info: https://releases.llvm.org/17.0.1/projects/libcxx/docs/BuildingLibcxx.html#support-for-windows
        message(FATAL_ERROR "libcxx requiries MSVC 19.14 or newer.")
    endif()
    list(APPEND LLVM_ENABLE_RUNTIMES "libcxx")
endif()
if("libcxxabi" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "libcxxabi")
endif()
if("libunwind" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "libunwind")
endif()
if("compiler-rt" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "compiler-rt")
    vcpkg_check_features(
        OUT_FEATURE_OPTIONS COMPILER_RT_FEATURE_OPTIONS
        FEATURES
            enable-ios COMPILER_RT_ENABLE_IOS
    )
endif()
if("openmp" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "openmp")
endif()

# this is for normal targets
set(known_llvm_targets
    AArch64
    AMDGPU
    ARM
    AVR
    BPF
    Hexagon
    Lanai
    LoongArch
    Mips
    MSP430
    NVPTX
    PowerPC
    RISCV
    Sparc
    SPIRV
    SystemZ
    VE
    WebAssembly
    X86
    XCore
)

set(LLVM_TARGETS_TO_BUILD)
foreach(llvm_target IN LISTS known_llvm_targets)
    string(TOLOWER "target-${llvm_target}" feature_name)
    if(feature_name IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "${llvm_target}")
    endif()
endforeach()

# this is for experimental targets
set(known_llvm_experimental_targets
    ARC
    CSKY
    DirectX
    M68k
    Xtensa
)

set(LLVM_EXPERIMENTAL_TARGETS_TO_BUILD)
foreach(llvm_target IN LISTS known_llvm_experimental_targets)
    string(TOLOWER "target-${llvm_target}" feature_name)
    if(feature_name IN_LIST FEATURES)
        list(APPEND LLVM_EXPERIMENTAL_TARGETS_TO_BUILD "${llvm_target}")
    endif()
endforeach()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")

file(REMOVE "${SOURCE_PATH}/llvm/cmake/modules/Findzstd.cmake")

if("${LLVM_ENABLE_RUNTIMES}" STREQUAL "")
    list(APPEND FEATURE_OPTIONS
        -DLLVM_INCLUDE_RUNTIMES=OFF
        -DLLVM_BUILD_RUNTIMES=OFF
        -DLLVM_BUILD_RUNTIME=OFF
    )
endif()

# At least one target must be specified, otherwise default to "all".
if("${LLVM_TARGETS_TO_BUILD}" STREQUAL "")
    set(LLVM_TARGETS_TO_BUILD "all")
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS
        -DLLVM_NATIVE_TOOL_DIR="${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/llvm"
    OPTIONS
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_BUILD_EXAMPLES=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF
        -DLLVM_INCLUDE_BENCHMARKS=OFF
        -DLLVM_BUILD_BENCHMARKS=OFF
        # Force TableGen to be built with optimization. This will significantly improve build time.
        -DLLVM_OPTIMIZED_TABLEGEN=ON
        -DPACKAGE_VERSION=${VERSION}
        # Limit the maximum number of concurrent link jobs to 1. This should fix low amount of memory issue for link.
        -DLLVM_PARALLEL_LINK_JOBS=1
        -DLLVM_INSTALL_PACKAGE_DIR:PATH=share/${PORT}
        -DLLVM_TOOLS_INSTALL_DIR:PATH=tools/${PORT}
        "-DLLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS}"
        "-DLLVM_ENABLE_RUNTIMES=${LLVM_ENABLE_RUNTIMES}"
        "-DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}"
        "-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=${LLVM_EXPERIMENTAL_TARGETS_TO_BUILD}"
        ${FEATURE_OPTIONS}
        ${CLANG_FEATURE_OPTIONS}
        ${COMPILER_RT_FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

function(llvm_cmake_package_config_fixup package_name)
    cmake_parse_arguments("arg" "DO_NOT_DELETE_PARENT_CONFIG_PATH" "FEATURE_NAME;CONFIG_PATH" "" ${ARGN})
    if(NOT DEFINED arg_FEATURE_NAME)
        set(arg_FEATURE_NAME ${package_name})
    endif()
    if("${arg_FEATURE_NAME}" STREQUAL "${PORT}" OR "${arg_FEATURE_NAME}" IN_LIST FEATURES)
        set(args)
        list(APPEND args PACKAGE_NAME "${package_name}")
        if(arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
            list(APPEND args "DO_NOT_DELETE_PARENT_CONFIG_PATH")
        endif()
        if(arg_CONFIG_PATH)
            list(APPEND args "CONFIG_PATH" "${arg_CONFIG_PATH}")
        endif()
        vcpkg_cmake_config_fixup(${args})
        file(INSTALL "${SOURCE_PATH}/${arg_FEATURE_NAME}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${package_name}" RENAME copyright)
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${package_name}_usage")
            file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${package_name}_usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${package_name}" RENAME usage)
        endif()
    endif()
endfunction()

llvm_cmake_package_config_fixup("clang" DO_NOT_DELETE_PARENT_CONFIG_PATH)
llvm_cmake_package_config_fixup("flang" DO_NOT_DELETE_PARENT_CONFIG_PATH)
llvm_cmake_package_config_fixup("lld" DO_NOT_DELETE_PARENT_CONFIG_PATH)
llvm_cmake_package_config_fixup("mlir" DO_NOT_DELETE_PARENT_CONFIG_PATH)
llvm_cmake_package_config_fixup("polly" DO_NOT_DELETE_PARENT_CONFIG_PATH)
llvm_cmake_package_config_fixup("llvm")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# Move Clang's runtime libraries from bin/lib to tools/${PORT}/lib
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/lib")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/lib" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/lib")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/lib")
endif()

# Remove debug headers and tools
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/debug/tools"
    )
endif()

# LLVM generates shared libraries in a static build (LLVM-C.dll, libclang.dll, LTO.dll, Remarks.dll, ...)
# for the corresponding export targets (used in LLVMExports-<config>.cmake files on the Windows platform)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()