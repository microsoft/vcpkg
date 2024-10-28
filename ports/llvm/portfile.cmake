vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO llvm/llvm-project
    REF "llvmorg-${VERSION}"
    SHA512 9e9ec501336127339347c01ffd47768d501a84ef415c6a72fe56d31e867f982baeb3c4659be8e9b8475848a460357f33a6b2aa0ee9f81150e363963b98387bc0
    HEAD_REF main
    PATCHES
        0001-fix-install-package-dir.patch
        0002-fix-tools-install-dir.patch
        0003-fix-llvm-config.patch
        0004-disable-libomp-aliases.patch
        0005-remove-numpy.patch
        0006-create-destination-mlir-directory.patch
        75711.patch # [clang] Add intrin0.h header to mimic intrin0.h used by MSVC STL for clang-cl #75711
        79694.patch # [SEH] Ignore EH pad check for internal intrinsics #79694
        82407.patch # [Clang][Sema] Fix incorrect rejection default construction of union with nontrivial member #82407
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
        enable-terminfo LLVM_ENABLE_TERMINFO
        enable-ios COMPILER_RT_ENABLE_IOS
        enable-eh LLVM_ENABLE_EH
        enable-bindings LLVM_ENABLE_BINDINGS
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

set(LLVM_ENABLE_PROJECTS)
if("bolt" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "bolt")
    list(APPEND FEATURE_OPTIONS
        -DBOLT_TOOLS_INSTALL_DIR:PATH=tools/llvm
    )
endif()
if("clang" IN_LIST FEATURES OR "clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang")
    list(APPEND FEATURE_OPTIONS
        -DCLANG_INSTALL_PACKAGE_DIR:PATH=share/clang
        -DCLANG_TOOLS_INSTALL_DIR:PATH=tools/llvm
        # Disable ARCMT
        -DCLANG_ENABLE_ARCMT=OFF
        # Disable static analyzer
        -DCLANG_ENABLE_STATIC_ANALYZER=OFF
    )
    # 1) LLVM/Clang tools are relocated from ./bin/ to ./tools/llvm/ (CLANG_TOOLS_INSTALL_DIR=tools/llvm)
    # 2) Clang resource files should be relocated from lib/clang/<major_version> to ../tools/llvm/lib/clang/<major_version>
    string(REGEX MATCH "^[0-9]+" CLANG_VERSION_MAJOR ${VERSION})
    list(APPEND FEATURE_OPTIONS -DCLANG_RESOURCE_DIR=lib/clang/${CLANG_VERSION_MAJOR})
endif()
if("clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang-tools-extra")
endif()
if("compiler-rt" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "compiler-rt")
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
if("libclc" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "libclc")
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
if("openmp" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "openmp")
    # Perl is required for the OpenMP run-time
    vcpkg_find_acquire_program(PERL)
    list(APPEND FEATURE_OPTIONS
        -DLIBOMP_INSTALL_ALIASES=OFF
        -DOPENMP_ENABLE_LIBOMPTARGET=OFF # Currently libomptarget cannot be compiled on Windows or MacOS X.
        -DOPENMP_ENABLE_OMPT_TOOLS=OFF # Currently tools are not tested well on Windows or MacOS X.
        -DPERL_EXECUTABLE=${PERL}
    )
endif()
if("polly" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "polly")
    list(APPEND FEATURE_OPTIONS
        -DPOLLY_INSTALL_PACKAGE_DIR:PATH=share/polly
    )
endif()

set(LLVM_ENABLE_RUNTIMES)
if("libc" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_RUNTIMES "libc")
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
    list(APPEND FEATURE_OPTIONS
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON
    )
else()
    list(APPEND FEATURE_OPTIONS
        -DLIBCXXABI_USE_LLVM_UNWINDER=OFF
    )
endif()
if("pstl" IN_LIST FEATURES)
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message(FATAL_ERROR "Building pstl with MSVC is not supported.")
    endif()
    list(APPEND LLVM_ENABLE_RUNTIMES "pstl")
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
    SPIRV
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
vcpkg_add_to_path("${PYTHON3_DIR}")

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
        -DLLVM_INSTALL_PACKAGE_DIR:PATH=share/llvm
        -DLLVM_TOOLS_INSTALL_DIR:PATH=tools/llvm
        "-DLLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS}"
        "-DLLVM_ENABLE_RUNTIMES=${LLVM_ENABLE_RUNTIMES}"
        "-DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}"
        "-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=${LLVM_EXPERIMENTAL_TARGETS_TO_BUILD}"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES 
        COMPILER_RT_ENABLE_IOS
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
llvm_cmake_package_config_fixup("ParallelSTL" FEATURE_NAME "pstl" DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH "lib/cmake/ParallelSTL")
llvm_cmake_package_config_fixup("llvm")

if("mlir" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mlir/MLIRConfig.cmake" "set(MLIR_MAIN_SRC_DIR \"${SOURCE_PATH}/mlir\")" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mlir/MLIRConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "\${MLIR_INCLUDE_DIRS}")
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# Move Clang's runtime libraries from bin/lib to tools/${PORT}/lib
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/lib")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/lib" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/lib")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/lib")
endif()

# Remove empty directories to avoid vcpkg warning
set(empty_dirs)
if("clang-tools-extra" IN_LIST FEATURES)
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/clang-tidy/plugin")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/clang-tidy/misc/ConfusableTable")
endif()
if("pstl" IN_LIST FEATURES)
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/lib/cmake")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
    endif()
endif()
if("flang" IN_LIST FEATURES)
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/CMakeFiles")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Config")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Optimizer/CMakeFiles")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Optimizer/CodeGen/CMakeFiles")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Optimizer/Dialect/CMakeFiles")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Optimizer/HLFIR/CMakeFiles")
    list(APPEND empty_dirs "${CURRENT_PACKAGES_DIR}/include/flang/Optimizer/Transforms/CMakeFiles")
endif()
if(empty_dirs)
    foreach(empty_dir IN LISTS empty_dirs)
        if(NOT EXISTS "${empty_dir}")
            message(WARNING "Directory '${empty_dir}' does not exist. Please remove it from the list of empty directories.")
        else()
            file(GLOB_RECURSE files_in_dir "${empty_dir}/*")
            if(files_in_dir)
                message(WARNING "Directory '${empty_dir}' is not empty. Please remove it from the list of empty directories.")
            else()
                file(REMOVE_RECURSE "${empty_dir}")
            endif()
        endif()
    endforeach()
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