list(APPEND Z_VCPKG_ACQUIRE_MSYS_DECLARE_PACKAGE_COMMANDS "z_vcpkg_find_fortran_declare_msys_packages")

function(vcpkg_find_fortran out_var)
    if("${ARGC}" GREATER "1")
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra args: ${ARGN}")
    endif()

    vcpkg_list(SET additional_cmake_args)

    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    macro(z_vcpkg_warn_ambiguous_system_variables)
    # CMakeDetermineFortranCompiler is for project mode.
    endmacro()
    include(CMakeDetermineFortranCompiler)

    if(NOT CMAKE_Fortran_COMPILER AND "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" STREQUAL "")
        # If a user uses their own VCPKG_CHAINLOAD_TOOLCHAIN_FILE, they _must_ figure out fortran on their own.
        if(CMAKE_HOST_WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Using MinGW gfortran!")
            # If no Fortran compiler is on the path we switch to use gfortan from MinGW within vcpkg
            if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86")
                message(FATAL_ERROR "vcpkg's internal MinGW Fortran compiler is no longer available for x86. "
                    "The MSYS2 mingw-w64-i686-gcc-fortran package has been removed upstream. "
                    "Please use an external Fortran compiler via VCPKG_CHAINLOAD_TOOLCHAIN_FILE, or target x64 instead.")
            elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
                set(mingw_path mingw64)
                set(machine_flag -m64)
                vcpkg_acquire_msys(msys_root
                    NO_DEFAULT_PACKAGES
                    Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_fortran_msys_declare_packages"
                    PACKAGES mingw-w64-x86_64-gcc-fortran
                )
            else()
                message(FATAL_ERROR "Unknown architecture '${VCPKG_TARGET_ARCHITECTURE}' for MinGW Fortran build!")
            endif()

            set(mingw_bin "${msys_root}/${mingw_path}/bin")
            vcpkg_add_to_path(PREPEND "${mingw_bin}")
            vcpkg_list(APPEND additional_cmake_args
                -DCMAKE_GNUtoMS=ON
                "-DCMAKE_Fortran_COMPILER=${mingw_bin}/gfortran.exe"
                "-DCMAKE_C_COMPILER=${mingw_bin}/gcc.exe"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING= -mabi=ms ${machine_flag} ${VCPKG_Fortran_FLAGS}")

            # This is for private use by vcpkg-gfortran
            set(vcpkg_find_fortran_MSYS_ROOT "${msys_root}" PARENT_SCOPE)
            set(VCPKG_USE_INTERNAL_Fortran TRUE PARENT_SCOPE)
            set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled PARENT_SCOPE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake" PARENT_SCOPE) # Switching to MinGW toolchain for Fortran
            if(VCPKG_CRT_LINKAGE STREQUAL "static")
                set(VCPKG_CRT_LINKAGE dynamic PARENT_SCOPE)
                message(STATUS "VCPKG_CRT_LINKAGE linkage for ${PORT} using vcpkg's internal gfortran cannot be static due to linking against MinGW libraries. Forcing dynamic CRT linkage")
            endif()
            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
                message(STATUS "VCPKG_LIBRARY_LINKAGE linkage for ${PORT} using vcpkg's internal gfortran cannot be static due to linking against MinGW libraries. Forcing dynamic library linkage")
            endif()
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set("${out_var}" "${additional_cmake_args}" PARENT_SCOPE)
endfunction()

macro(z_vcpkg_find_fortran_msys_declare_packages)
    # primary package for x64
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-16.1.0-1-any.pkg.tar.zst"
        SHA512 8974cd4f28dd7e793d851063d0cfed8312912e643daa183e09cf57788ad5767db7f41aa2b4a5f5cade07d7a59e1e81183ff023799300be4ecb3332a8291a167d
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-isl mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.46-2-any.pkg.tar.zst"
        SHA512 3b1438b40a98ceda3dc48be49c691fda7288e7552db4f950d3570cb890bb3c516081c7c1a9cc30672f391955d750dc30d2668b222127b28a05bb401f46c819ae
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-14.0.0.r14.g4761eabdd-1-any.pkg.tar.zst"
        SHA512 cd6dfd351ea5121ece322893284e31d6b950c3dc0539ece4de5398f80d9096fe32ad0df18f8a1237e7746e2bc3e1bcc1de422ddb3d11a8f55c31cde094be1119
        PROVIDES mingw-w64-x86_64-crt-git
        DEPS mingw-w64-x86_64-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-16.1.0-1-any.pkg.tar.zst"
        SHA512 86581883d08585603c8145be944de185898a103992e55dc974a6adc9a41e8fa48954f4d2aa825b5c06cb50576eeebd9c656f44ddbd747fd3470f53d15045ce7c
        PROVIDES mingw-w64-x86_64-gcc-base mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-14.0.0.r14.g4761eabdd-1-any.pkg.tar.zst"
        SHA512 dd70dcfcb0e46447b4bc2c6aef8325f2526679c6c377304a7c01c39228d0adc9c72d1987862e32a689a195cdf935a0517a5140a2a2a205147f8d5507757e5d94
        PROVIDES mingw-w64-x86_64-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.27-1-any.pkg.tar.zst"
        SHA512 879e3a6748f552b9c3574090b8d45fd83ff1cb843eae3924e6025464ecfc9d4883bd3d9e9dbcd54481820a6f5a01b33e3dc8e2c90bc812d8173412ee01a08110
        DEPS mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
        SHA512 d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-14.0.0.r14.g4761eabdd-1-any.pkg.tar.zst"
        SHA512 6708866106e729750708ab094da953d0ae162a1b46b8045c24e0c8612194f98667e842576f82b01111905b7471966b2cf6b331624a8aaac8812df416bcf7119c
        PROVIDES mingw-w64-x86_64-winpthreads-git
        DEPS mingw-w64-x86_64-crt mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.7-1-any.pkg.tar.zst"
        SHA512 35b8dfb55b22de813ca29cf2c38fe2912616c66c211706ea39551936c3d3b80b663a3d7e57698ca2300d026d9966fe6a36193a1e3503f3ca538f3e9e8ce75b55
        DEPS  mingw-w64-x86_64-gcc-libs
    )
endmacro()