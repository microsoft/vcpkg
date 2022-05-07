vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # unresolved symbol interr
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_download_distfile(
    PATCH_572
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/572.diff"
    FILENAME 572.diff
    SHA512 7bc8038f548ab141c1d5d8e7a93ffd72b0412a5ce3978831de0dd06e7e33ac2839924f8d97b56563cf6bc7e7bda005bc936c51ae15c5ffc4a4aceccc3f55a995
)

vcpkg_download_distfile(
    PATCH_1163
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1163.diff"
    FILENAME 1163.diff
    SHA512 e6c7be92dc2fcbe77056e58647d9f2074cc3dac81b25d15241ec0cbdc5d45658000c4764b1828e997d93738d839b1cccc2cfe7806d77ad8b4d0ea6107a7a15dc
)

vcpkg_download_distfile(
    PATCH_1165
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1165.diff"
    FILENAME 1165.diff
    SHA512 4202b5a9f9ea5c84525939e44bea6cf3514d1d948768d899fdf0db6f0d71ee45ce187bfea68742f7a332878335f43103df1e215fb70e1b60035f48d93f04db64
)

vcpkg_download_distfile(
    PATCH_1166
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1166.diff"
    FILENAME 1166.diff
    SHA512 68cb37acbabd69285481c6baa38bb3ea61497268f39bb90e2384c6a6cbea9860d54554d5dd206ebfe77ef5610fd9dc93cd6da6000d6c22e274c2e635e23ff997
)

vcpkg_download_distfile(
    PATCH_1168
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1168.diff"
    FILENAME 1168.diff
    SHA512 1efe6e8db18dd3834386801fb055bdcdb4a65987855a95175c6817ba30f3f34e8677e35836dc5b934edcd28e34ccf42273409970fa5bd6de85beb3e1d60d90d4
)

# Needs a rebase
#vcpkg_download_distfile( 
#    PATCH_1177
#    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1177.diff"
#    FILENAME 1177.diff
#    SHA512 e00dfbf70449a407919cdf4737beeb87614e009519abe20dd9213117447485e551e094c33460104378b925f1ba889e112c6ce86cc994338a4a9e028d587a59e2
#)

vcpkg_download_distfile(
    PATCH_1178
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1178.diff"
    FILENAME 1178.diff
    SHA512 68b66f69c796cdfcf952e820ba47c02f9239ad0b59779fa364f7f58028e7771a3ca5b72c70386203f41ed3b85309473c7d2116d81c2c2ef15130ffa047ead863
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 0df85a22ae141078658569a0e1b3745afd702e45
    SHA512 f7195fbf0885dd767ff7f8ab48688586f4c9995dc81d619d4a315e3a3a8b1af019232410aa4eff1e85ed910281338dc6ebb54f55d34534c3d92766b6e1a74149
    PATCHES awk.patch
            "${PATCH_572}"
            "${PATCH_1163}"
            "${PATCH_1165}"
            "${PATCH_1166}"
            "${PATCH_1168}"
            "1177.diff"
            "${PATCH_1178}"
            move_flang2.patch
            cross.patch
            sep_runtime_from_compiler.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        vcpkg_list(SET OPTIONS 
                    "-DCMAKE_C_COMPILER=${CLANG_CL}"
                    "-DCMAKE_CXX_COMPILER=${CLANG_CL}"
                    "-DCMAKE_AR=${VCPKG_DETECTED_CMAKE_AR}"
                    "-DCMAKE_LINKER=${VCPKG_DETECTED_CMAKE_LINKER}"
                    "-DCMAKE_MT=${VCPKG_DETECTED_CMAKE_MT}"
                    )
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            string(APPEND VCPKG_C_FLAGS " --target=aarch64-win32-msvc")
            string(APPEND VCPKG_CXX_FLAGS " --target=aarch64-win32-msvc")
        endif()
    endif()
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON)
    endif()
endif()

set(VCPKG_BUILD_TYPE release)

# Búild AMD64 compiler
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #"-DLLVM_TARGETS_TO_BUILD=X86;AArch64"
        "-DFLANG_BUILD_RUNTIME=OFF"
        "-DTARGET_ARCHITECTURE=AMD64"
        "-DFLANG_LLVM_EXTENSIONS=ON"
        "-DFLANG_INCLUDE_DOCS=OFF"
        "-DLLVM_INCLUDE_TESTS=OFF"
        "-DFLANG_BUILD_TOOLS=ON"
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
        "-DLLVM_CONFIG=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/lib/cmake/llvm" # Flang does not link against anything in llvm
        #"-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
        #"-DCMAKE_Fortran_COMPILER_ID=Flang"
        ${OPTIONS}
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

# Búild ARM compiler
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #"-DLLVM_TARGETS_TO_BUILD=X86;AArch64"
        "-DFLANG_BUILD_RUNTIME=OFF"
        "-DTARGET_ARCHITECTURE=ARM64"
        "-DFLANG_LLVM_EXTENSIONS=ON"
        "-DFLANG_BUILD_TOOLS=ON"
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
        "-DLLVM_CONFIG=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/lib/cmake/llvm" # Flang does not link against anything in llvm
        #"-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
        #"-DCMAKE_Fortran_COMPILER_ID=Flang"
        ${OPTIONS}
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/bin" )
file(RENAME "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/lib" )

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)