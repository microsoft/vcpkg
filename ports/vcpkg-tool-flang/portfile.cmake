vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 59c43c4d99ade23d103aaf5299016a1666ceb2e1
    SHA512 467c3a977d5a207a0115ece5db070c9b49c1b57595155d477d25fe0b49453facbc90566b6e5ae7a48038b59bda7481b4ed6cd969628f3019076864be74a3d6a3
    PATCHES awk.patch
            #warnings.patch
            #flang-stub.patch
            #288.diff
            1163.diff
            1165.diff
            1166.diff
            1168.diff
            1177.diff
            1178.diff
            1210.diff
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    find_program(LIB NAMES lib)
    vcpkg_list(SET OPTIONS 
                "-DCMAKE_C_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                "-DCMAKE_CXX_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                "-DCMAKE_AR=${LIB}"
                "-DCMAKE_LINKER=link.exe"
                "-DCMAKE_MT=mt.exe"
                )
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()
set(VCPKG_BUILD_TYPE release)
set(CURRENT_PACKAGES_DIR_BAK "${CURRENT_PACKAGES_DIR}")
set(CURRENT_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}/tools/llvm-flang")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLLVM_TARGETS_TO_BUILD=X86
        -DFLANG_LLVM_EXTENSIONS=ON
        "-DLLVM_CONFIG=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/lib/cmake/llvm"
        "-DCMAKE_Fortran_COMPILER=${CURRENT_INSTALLED_DIR}/tools/llvm-flang/bin/flang.exe"
        "-DCMAKE_Fortran_COMPILER_ID=Flang"
        #"-DBOOTSTRAP=ON"
        ${OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

set(CURRENT_PACKAGES_DIR "${CURRENT_PACKAGES_DIR_BAK}")
# set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) #-static-flang-libs
