vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 59c43c4d99ade23d103aaf5299016a1666ceb2e1
    SHA512 467c3a977d5a207a0115ece5db070c9b49c1b57595155d477d25fe0b49453facbc90566b6e5ae7a48038b59bda7481b4ed6cd969628f3019076864be74a3d6a3
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})
set(VCPKG_BUILD_TYPE release)
vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash)
vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/runtime/libpgmath"
    OPTIONS
        -DLLVM_TARGETS_TO_BUILD=X86
        -DFLANG_LLVM_EXTENSIONS=ON
        "-DLLVM_CONFIG=${CURRENT_INSTALLED_DIR}/tools/llvm/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_INSTALLED_DIR}/share/llvm-flang"
        #"-DLIBPGMATH_LLVM_LIT_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/llvm-lit.py"
        "-DCMAKE_C_COMPILER=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/clang-cl.exe"
        "-DCMAKE_CXX_COMPILER=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/clang-cl.exe"
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLLVM_TARGETS_TO_BUILD=X86
        -DFLANG_LLVM_EXTENSIONS=ON
        "-DLLVM_CONFIG=${CURRENT_INSTALLED_DIR}/tools/llvm/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_INSTALLED_DIR}/share/llvm-flang"
        -DCMAKE_Fortran_COMPILER=${CURRENT_PACKAGES_DIR}/bin/flang
        -DCMAKE_Fortran_COMPILER_ID=Flang
        "-DLIBPGMATH_LLVM_LIT_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/llvm/llvm-lit.py"
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)


set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
