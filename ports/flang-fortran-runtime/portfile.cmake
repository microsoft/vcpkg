vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # unresolved symbol interr

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 5a60d344443e38715b7c837de53d9ce2ed78b0d6
    SHA512 aff012c3cf9756d84b8bb5d0c369a1fd78d51af4cb2734183640e7fdcc16f6e6ab2ab78a56cc4b750f1571f7842b2b76b255e442df98e0aacd5e07db6a9d6a82
    PATCHES awk.patch
            1163.diff
            1165.diff
            1166.diff
            1168.diff
            1177.diff
            1178.diff
            1210.diff
            move_flang2.patch
            cross.patch
            sep_runtime_from_compiler.patch
)

set(NINJA "${CURRENT_HOST_INSTALLED_DIR}/tools/ninja/ninja${VCPKG_HOST_EXECUTABLE_SUFFIX}")
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    get_filename_component(COMPILER_FILENAME "${VCPKG_DETECTED_CMAKE_C_COMPILER}" NAME)
    if(COMPILER_FILENAME STREQUAL "cl.exe")
        vcpkg_list(SET OPTIONS 
                    "-DCMAKE_C_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                    "-DCMAKE_CXX_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                    "-DCMAKE_AR=${VCPKG_DETECTED_CMAKE_AR}"
                    "-DCMAKE_LINKER=${VCPKG_DETECTED_CMAKE_LINKER}"
                    "-DCMAKE_MT=${VCPKG_DETECTED_CMAKE_MT}"
                    )
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            string(APPEND VCPKG_C_FLAGS " --target=aarch64-win32-msvc")
            string(APPEND VCPKG_CXX_FLAGS " --target=aarch64-win32-msvc")
            vcpkg_list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows -DCMAKE_Fortran_FLAGS=--target=aarch64-win32-msvc)
        endif()
    endif()
    vcpkg_list(APPEND OPTIONS 
                    "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
                    "-DCMAKE_Fortran_COMPILER_ID=Flang"
              )

    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH X86)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ARCH ARM)
    endif()
    vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/${ARCH}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #"-DLLVM_TARGETS_TO_BUILD=X86;AArch64"
        "-DFLANG_BUILD_RUNTIME=ON"
        "-DFLANG_LLVM_EXTENSIONS=ON"
        "-DFLANG_INCLUDE_DOCS=OFF"
        "-DLLVM_INCLUDE_TESTS=OFF"
        "-DFLANG_BUILD_TOOLS=OFF"
        "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}"
        "-DLLVM_CONFIG=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/llvm-config.exe"
        "-DLLVM_CMAKE_PATH=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/lib/cmake/llvm" # Flang does not link against anything in llvm

        ${OPTIONS}
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

#file(GLOB_RECURSE allbinfiles "${CURRENT_PACKAGES_DIR}/bin/*")
#file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/")
#file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/bin" )
#file(GLOB_RECURSE alllibfiles "${CURRENT_PACKAGES_DIR}/lib/*")
#file(RENAME "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/lib" )

#file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/manual-tools/llvm-flang/include" )

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)