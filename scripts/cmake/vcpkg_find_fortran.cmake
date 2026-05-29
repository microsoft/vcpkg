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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-15.2.0-8-any.pkg.tar.zst"
        SHA512 141bb2f0a71b636ea21839396f430015f06a387bf86ff6c001699487fa07e369120ff7ad81448dff8a4ca362b4e6740d2d7ae39347614245ef5546e8506a6463
        PROVIDES mingw-w64-i686-fc
        DEPS mingw-w64-i686-gcc mingw-w64-i686-gcc-libgfortran mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-isl mingw-w64-i686-libwinpthread mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.45.1-1-any.pkg.tar.zst"
        SHA512 fc936475811f6367f76c41fcc64ee0658e4087d96f6202284346c070bfd57d870c40fa22457a7f395927b5fa44cb54ae1bc4a9535cb5d41914f51f67264b9e15
        DEPS mingw-w64-i686-gettext-runtime mingw-w64-i686-libwinpthread mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 2cc57391e5de42f4eb316007fb67de7b992daa519852e31bbfc33e841676680a56c1f19b5ac83cde35424e47dfe5c7552369a11238b46cbd9717f69f040d6c74
        PROVIDES mingw-w64-i686-crt-git
        DEPS mingw-w64-i686-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-15.2.0-8-any.pkg.tar.zst"
        SHA512 16cfbe9cb6dfa41ca5848b8922d7f1beec09ceb70eb1477a534c19f9b6c8be38b85aa81b13b4d681e3c439e28e4e21de7caa866238549e175c8b076a61fd37ae
        PROVIDES mingw-w64-i686-gcc-base mingw-w64-i686-cc
        DEPS mingw-w64-i686-binutils mingw-w64-i686-crt mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-headers mingw-w64-i686-isl mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-windows-default-manifest mingw-w64-i686-winpthreads mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-15.2.0-8-any.pkg.tar.zst"
        SHA512 3121c9d686940c2917e779eaeefa8c574eea3343f0c8a5cea130a12fe52ef52dede40df7fd1bce88fe12f7885342297c72f7185ca6d4f5fd8272087e1f113304
        PROVIDES mingw-w64-i686-fc-libs
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-15.2.0-8-any.pkg.tar.zst"
        SHA512 a6227c930baef588fc07f20aa154387d629a47a62d754d0cbfd3857e76ec3c35acc0cde2f581d26089d68b0ac4a5361c7281541e0498492cb4360f0d1aa3f69d
        PROVIDES mingw-w64-i686-omp mingw-w64-i686-cc-libs
        DEPS mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gettext-runtime-0.26-2-any.pkg.tar.zst"
        SHA512 39f3a292eaca8285d42d68585cd039d048bc61773c4bc49630a214358f5bb34da0346afb07680274bdb35882ce4c36b9e9398524745f464405c94a8076ef6fa1
        DEPS mingw-w64-i686-cc-libs mingw-w64-i686-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 ce84caa2807ffd715836e9ceb930ce5ddc5f45c5c2593a40efa9de18f085284919e4b49a92a452dfe66689995d39cefb7f57afc81914aa3d26827dc8c03196fb
        PROVIDES mingw-w64-i686-headers-git
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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 b6d73cf15d72ef83faaa61250eaab34cd0fffdc510cdb192c3e657fa37bd08d417cd58dffc20a0a875019cbab977a0a9bc27ce65a8964506a722ebaff22725d9
        PROVIDES mingw-w64-i686-libwinpthread-git
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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 67b2fae41bdf80beee53e4ea87fecf689a5f50b934c207ebcb11f309c671d46dc0b08bce872659468e24780894f751c7694e747542247ee46d7258e629778a0a
        PROVIDES mingw-w64-i686-winpthreads-git
        DEPS mingw-w64-i686-crt mingw-w64-i686-libwinpthread
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-15.2.0-8-any.pkg.tar.zst"
        SHA512 8b05c50499a9aa55e68dc8f165af7010ae62667564eecf45466f1ade0795269730fd05c616811b5e9480733281fe0842de54b4e1aed90c89ec33858eb08ae327
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-isl mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.45.1-1-any.pkg.tar.zst"
        SHA512 0f53fc62006063ad933d7287a7575a8a9342e0954cd611c97b992a54298dea01298fed98cd420843b6098d1654ad230fdc39e375134f1ee74bffd3c652604416
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 095955c464725fe5d0aa9668ddfb5502deacfa42547e4d829d7a8133d02ba1515e4d7842642d46e2695e7746ab97ba3aea6443dbc9a180f2a77bd8b9dddbbccf
        PROVIDES mingw-w64-x86_64-crt-git
        DEPS mingw-w64-x86_64-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-15.2.0-8-any.pkg.tar.zst"
        SHA512 d478acf7f206fdf292cb1b4611721cc1a7c31eb1615e2ef29fd4da75f6d3db009e91eff10a08dff6ba51a19877b0a8038eba3030d373cb780d9c5e4df2314c8f
        PROVIDES mingw-w64-x86_64-gcc-base mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 c6d2eb9a7d76514dfe3ef807aadcd9fb5e2780308d3dfbba41fcac9734b046b4577eebdeebd0864f6db103f7d79b41bf8840f00f331e41f4ace22239e5780999
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-13.0.0.r391.g848cce552-1-any.pkg.tar.zst"
        SHA512 3ad4f8d55a2d6929bc13c833c3825592c83506a810e83295d619c5382ee9c6fa1a5ea071f84784ee02b3a9c655e49fae109acc14bb157e68ba0e77c63b0a5e56
        PROVIDES mingw-w64-x86_64-winpthreads-git
        DEPS mingw-w64-x86_64-crt mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.7-1-any.pkg.tar.zst"
        SHA512 35b8dfb55b22de813ca29cf2c38fe2912616c66c211706ea39551936c3d3b80b663a3d7e57698ca2300d026d9966fe6a36193a1e3503f3ca538f3e9e8ce75b55
        DEPS  mingw-w64-x86_64-gcc-libs
    )
endmacro()