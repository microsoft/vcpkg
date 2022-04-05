if(VCPKG_CROSSCOMPILING)
    set(PATCHES cross.patch)
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # unresolved symbol interr
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 59c43c4d99ade23d103aaf5299016a1666ceb2e1
    SHA512 467c3a977d5a207a0115ece5db070c9b49c1b57595155d477d25fe0b49453facbc90566b6e5ae7a48038b59bda7481b4ed6cd969628f3019076864be74a3d6a3
    PATCHES awk.patch
            1163.diff
            1165.diff
            1166.diff
            1168.diff
            1177.diff
            1178.diff
            1210.diff
            move_flang2.patch
            ${PATCHES}
)
set(NINJA "${CURRENT_HOST_INSTALLED_DIR}/tools/ninja/ninja${VCPKG_HOST_EXECUTABLE_SUFFIX}")
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

if(NOT VCPKG_CROSSCOMPILING)
  vcpkg_list(APPEND OPTIONS "-DFLANG_BUILD_TOOLS=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
          #--trace-expand
        -DLLVM_TARGETS_TO_BUILD=X86
        -DFLANG_LLVM_EXTENSIONS=ON
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
        "-DLLVM_CONFIG=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/lib/cmake/llvm" # Flang does not link against anything in llvm
        "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
        "-DCMAKE_Fortran_COMPILER_ID=Flang"
        ${OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

file(GLOB_RECURSE allbinfiles "${CURRENT_PACKAGES_DIR}/bin/*")
file(COPY ${allbinfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/bin" )
file(GLOB_RECURSE alllibfiles "${CURRENT_PACKAGES_DIR}/lib/*")
file(COPY ${allbinfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/lib" )

file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/include" )

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/flang1${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/bin/flang2${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/debug/bin/flang1${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/debug/bin/flang2${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)