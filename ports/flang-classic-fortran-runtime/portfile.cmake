vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # unresolved symbol interr

# Needs a rebase
#vcpkg_download_distfile( 
#    PATCH_1177
#    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1177.diff"
#    FILENAME 1177.diff
#    SHA512 e00dfbf70449a407919cdf4737beeb87614e009519abe20dd9213117447485e551e094c33460104378b925f1ba889e112c6ce86cc994338a4a9e028d587a59e2
#)

vcpkg_download_distfile( 
   PATCH_1346
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1346.diff"
   FILENAME 1346.diff
   SHA512 367fe2a6bfe36ef27b0a534f516a4bba20128967bae366dd5d3943913ad487faa83270adacecee1d42ba7e65d84a420a12ee9bb614e6eb4102f59f66b301608d
)

vcpkg_download_distfile( 
   PATCH_1345
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1345.diff"
   FILENAME 1345.diff
   SHA512 6387c96c075428b389b71f701fb79f6e2f676014f86d4229dcb3bdc3b188191780dcc53b354281b064b618886b3281fa432ecfb01872d7ba73fdf3b3e4a234a3
)

vcpkg_download_distfile( 
   PATCH_1344
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1344.diff"
   FILENAME 1344.diff
   SHA512 0b7432949aaae1ade0927e1c2d4c320bddc64bc65a901aba8451eae21475f16f72b2171904f69827e277aeea2f0d9cc0a40cbf11c7b99e4d09860f6c093f997a
)

vcpkg_download_distfile( 
   PATCH_1341
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1341.diff"
   FILENAME 1341.diff
   SHA512 ab3a2025d0e28b795d31e8907f1c36a4e282126751f7c74bc1896fa9176adc8574166d0facce25f7affa6f46e7c0636139ceeb08bc65b4d58c57d709d918875a
)

vcpkg_download_distfile( 
   PATCH_1340
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1340.diff"
   FILENAME 1340.diff
   SHA512 0843c91b957e7fd0680577e83c68ca8d68ea59775e59fdc4c2fd407d4a8f26dc8ea7335262636050783929e975ab0e548f6fdc770aa30996da1ec120c9619d6c
)

vcpkg_download_distfile( 
   PATCH_1335
   URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1335.diff"
   FILENAME 1335.diff
   SHA512 34b64481e97d1fc5b1e8739bba3af18d83b7d9905f078be4fd21ab1617806ba5f432975928de0d8fa9d512507a4324724900843f1db9b4479b0b974e6bd42cf2
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 2d211cfe258c23cdc197cba8c4df1e6a116b9764
    SHA512 a7b4c7959f086d0d0bbc6b775d714d6dbe355c3cd3a389f815df3e87aee6850f3a278896b2ba8ffb0a3b022d8c9a6bea6ebce0b5cc505fc41b511ebc033dc7d8
    PATCHES awk.patch
            "1177.diff"
            move_flang2.patch
            cross.patch
            sep_runtime_from_compiler.patch
            ${PATCH_1335}
            ${PATCH_1340}
            ${PATCH_1341}
            ${PATCH_1344}
            #${PATCH_1345}
            ${PATCH_1346}
			fix_win11_sdk.patch
)

set(NINJA "${CURRENT_HOST_INSTALLED_DIR}/tools/ninja/ninja${VCPKG_HOST_EXECUTABLE_SUFFIX}")
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
            vcpkg_list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON 
                                      -DCMAKE_Fortran_FLAGS=--target=aarch64-win32-msvc)
        endif()
    endif()
    vcpkg_list(APPEND OPTIONS 
                    "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/bin/flang.exe"
                    "-DCMAKE_Fortran_COMPILER_ID=Flang"
              )

    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH X86)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ARCH ARM)
    endif()
    vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/bin/${ARCH}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DWITH_WERROR:BOOL=OFF"
        #"-DLLVM_TARGETS_TO_BUILD=X86;AArch64"
        "-DFLANG_BUILD_RUNTIME=ON"
        "-DFLANG_LLVM_EXTENSIONS=ON"
        "-DFLANG_INCLUDE_DOCS=OFF"
        "-DLLVM_INCLUDE_TESTS=OFF"
        "-DFLANG_BUILD_TOOLS=OFF"
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
        "-DLLVM_CONFIG=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/lib/cmake/llvm" # Flang does not link against anything in llvm
        ${OPTIONS}
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)