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
                set(mingw_path mingw32)
                set(machine_flag -m32)
                vcpkg_acquire_msys(msys_root
                    NO_DEFAULT_PACKAGES
                    Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_fortran_msys_declare_packages"
                    PACKAGES mingw-w64-i686-gcc-fortran
                )
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
    # primary package for x86
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-15.1.0-5-any.pkg.tar.zst"
        SHA512 dd8633b15a2aeb9510410612b8e43e3ecdd61d89ada76d5aa1fa2b7f3273ac666027c56c5cbfcfdbe21a0309b4d3002f730acdfa3c693847db3cf92f914fb619
        PROVIDES mingw-w64-i686-fc
        DEPS mingw-w64-i686-gcc mingw-w64-i686-gcc-libgfortran mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-isl mingw-w64-i686-libwinpthread mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.44-3-any.pkg.tar.zst"
        SHA512 7ce793ec986313ffce56b59457365a0067737f7497520c8bbdee9e6585d16b1def4b8a73fbb302ce581e5cb3eaa959bfac3819c08b2c2e28f685bbcc0988088a
        DEPS mingw-w64-i686-gettext-runtime mingw-w64-i686-libwinpthread mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 f9a0250c0601014893152a68d3d430c03b01d9232510181b41b41a9a9bc11bf1e951ce853f070e96aedf40487d2a3b93018078dc770b8f3fcbf07dc6e1080835
        PROVIDES mingw-w64-i686-crt
        DEPS mingw-w64-i686-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-15.1.0-5-any.pkg.tar.zst"
        SHA512 754c5372dc9f63fd9783bc2e8f925c01b36805857efa73a619ef5163e0a740ea7b4c95ce1b44d5803f332da939bb3a09c14dc5379bb2d6b0b64deb31caeed3b3
        PROVIDES mingw-w64-i686-gcc-base mingw-w64-i686-cc
        DEPS mingw-w64-i686-binutils mingw-w64-i686-crt mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-headers mingw-w64-i686-isl mingw-w64-i686-libiconv mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-windows-default-manifest mingw-w64-i686-winpthreads mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-15.1.0-5-any.pkg.tar.zst"
        SHA512 320d956a85ca95407c26d206431e79d0f0c3aaf10f48870a72ec0ceebabbecb4f7d767c27b0d8284b024b1c116137c39751df64e20435d5f9cac61b34d8e5da0
        PROVIDES mingw-w64-i686-fc-libs
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-15.1.0-5-any.pkg.tar.zst"
        SHA512 8f8f547ff5343cb5132e90cb8632b0ac2091459510abaec5e4a2a1a77e88d57e644587e2f8fc06eca9c43fec3e8b12c3e803273980bd311a3d4350d635bd6015
        PROVIDES mingw-w64-i686-omp
        DEPS mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gettext-runtime-0.25-1-any.pkg.tar.zst"
        SHA512 e487f6c994e9997bf5a17e7ddb6d601def1b25bd38fa113aed6fe4c66af3071f93d751d593fae87eabf1b31f0796991c8333a619573f3d027cabb6b12a0abdd7
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 858057afb80945d61dd1aeb6de99d4c14b4eab37748f583f8f41be481afedf8ef46904b48f9f364624ce2b2c267ecfbb393e35fdfa0be409d3acd6c7ec3088e0
        PROVIDES mingw-w64-i686-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.27-1-any.pkg.tar.zst"
        SHA512 070e87552aa0ce77bb9db3b6104c7a3b0d9b5f3515dffc5d03d586693661a9c4681d54ffa6209203bdd568cf111ecae2b26df7472cf40144d6537d655d01b178
        DEPS mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.18-1-any.pkg.tar.zst"
        SHA512 c45f62552dd57e53b80b2aa541322586255c11846be92ee8554f0c336b9d3f93382cefab613ff3ba61b4cff30a3beb91ccb1f472d89470c4399de81515c52c95
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 ab5b2ecebf7809a9cc252ccc9e15d40bff28a7d63a332fbff8e230748fb4535491697495930f1b7d289f6d9e4fc6d2cd73baba284aaee19d93d2cbeeb5668ff8
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-2-any.pkg.tar.zst"
        SHA512 936acdedea20b9892f90ebdb0b75250d1ed3d65487316ee986b8672683b01d4e1f2922387f18ea8d6befb71bf273995d4940ff55b645d07996c98bd50c9382ae
        DEPS mingw-w64-i686-gmp mingw-w64-i686-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.2-1-any.pkg.tar.zst"
        SHA512 002964eaa63ee3f602c580cedb995564ffd45f2468088af4b7f2096e0da96b2537a377054c60d9550689a66fbe58eb476db581db6935a44685b5c5c097915323
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
        SHA512 103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 167b913ac66636e88624c7890fb7749423dce2708dec0e0b83a71baa445418d3439560b08a77af9992a313e7c00cf05a5776b3098c0bc1ea665f342fd3247491
        DEPS mingw-w64-i686-crt-git mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.3.1-1-any.pkg.tar.zst"
        SHA512 881cf37f59bfbc3d8a6a6d16226360b63cf3d5abc82bb25fa1d9f871aa3e620fa22a8ae6b0cec619633d08550b72ad289f16b75d5819e3e117de0607125b0140
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zstd-1.5.7-1-any.pkg.tar.zst"
        SHA512 fa266dd3628322629412e64ff0f092f2a233ba05a65305cfffbdeeb82d954f681ed23e381cb3a5886034c9723bd40fd993303bdbe99f26fe179a69f3f7f8c4b5
        DEPS mingw-w64-i686-gcc-libs
    )

    # primary package for x64
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-15.1.0-5-any.pkg.tar.zst"
        SHA512 042fbdfae03fa05cb297687b8b85f4e78237e4d4f8106c0763254caa7e3f93b341f507415dc6395cd2432461cb48c94de8c0828248e84cf99b369a81fa879813
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-isl mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.44-3-any.pkg.tar.zst"
        SHA512 67b0367389f481fc8da4a4d16ffa886a28ef994cb1726c84b5e43a1cbc648474359ed9c159444d09121b23972ad88f30db8934484b6ff7cbb4a67d5351c6dd7c
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 0568b22cb5686743a7b84f1655e65236c23d8911da9cb4ed4e984df737741fb4ec5430fe0f42bd7f5b8b021678828ad6fdf605885bac8318317a5cc2661706d6
        PROVIDES mingw-w64-x86_64-crt
        DEPS mingw-w64-x86_64-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-15.1.0-5-any.pkg.tar.zst"
        SHA512 283817fae25eeb1f2d97c4b07b2cad375617a8bf31a949369a6c9454ce345d864f5640db991ab04de8942ce2ef1ea08f6ee785e43f404807d3e04002736df636
        PROVIDES mingw-w64-x86_64-gcc-base mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-libiconv mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 0bb6b97449d423177cab7e2496850c6e00f858654fae8085eb2910f6fb67e403eff5a6cbd5cc45a28c22d9bf3bb27a138a55c43ecd52bfb020629bd98e81ed4c
        PROVIDES mingw-w64-x86_64-headers
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-12.0.0.r747.g1a99f8514-1-any.pkg.tar.zst"
        SHA512 e20ba4171f2f18230dac3f8dbc058e912741c005a124dcb9192ef3e5a349b000d6251a2aba1b462d0f98e8366260ccb8407b2c4ed5a345d5761b20e985566323
        DEPS mingw-w64-x86_64-crt-git mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.7-1-any.pkg.tar.zst"
        SHA512 35b8dfb55b22de813ca29cf2c38fe2912616c66c211706ea39551936c3d3b80b663a3d7e57698ca2300d026d9966fe6a36193a1e3503f3ca538f3e9e8ce75b55
        DEPS mingw-w64-x86_64-gcc-libs
    )
endmacro()