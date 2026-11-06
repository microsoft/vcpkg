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

    if(VCPKG_PROVIDED_FORTRAN)
        message(STATUS "Using MinGW gfortran; set VCPKG_PROVIDED_FORTRAN=OFF if supplying Fortran from your toolchain")
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
                PACKAGES mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-libgomp
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
    elseif(CMAKE_HOST_WIN32)
        message(STATUS "Deferring Fortran compiler selection to the triplet toolchain.")
    else()
        include(CMakeDetermineFortranCompiler)
        if(NOT CMAKE_Fortran_COMPILER)
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set("${out_var}" "${additional_cmake_args}" PARENT_SCOPE)
endfunction()

macro(z_vcpkg_find_fortran_msys_declare_packages)
    # primary package for x86
    # MSYS2 no longer publishes x86 Fortran. Keep its GCC and runtime packages
    # at the matching version so the compiler can still locate libgcc.
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-15.2.0-8-any.pkg.tar.zst"
        SHA512 141bb2f0a71b636ea21839396f430015f06a387bf86ff6c001699487fa07e369120ff7ad81448dff8a4ca362b4e6740d2d7ae39347614245ef5546e8506a6463
        PROVIDES mingw-w64-i686-fc
        DEPS mingw-w64-i686-gcc mingw-w64-i686-gcc-libgfortran mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-isl mingw-w64-i686-libwinpthread mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.47-3-any.pkg.tar.zst"
        SHA512 144fa4460b001b4fd0d0a05ba64f3c3af1f6fc9cb77459ea2ddb78dddbbcdc10552d7cce138c6db73eca85d98072f8d75e1b803d6b28a43d6e73a2bfec2d32ed
        DEPS mingw-w64-i686-gettext-runtime mingw-w64-i686-libwinpthread mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 74588735b3a80fef61872bf5bb8479dda38dd83aab98fb7f5366d5ad9bd9e7de6af2d7af9d3c2cdb9cc985aa14727e0cbf19c82c89a7efc25b8350f124b21bff
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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gettext-runtime-1.0-1-any.pkg.tar.zst"
        SHA512 ec2f4abaab2aa7994a974af5fdfa24aa7de81424a2ed19cbf4f3d0004b8fce5f23d498ed78c481c6f37792e75e6937c25835a9f9c2b6e4043f6dc908f5c72ca3
        DEPS mingw-w64-i686-cc-libs mingw-w64-i686-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 8e6afb7f3accb8e557bc4c736d54be83d489c86eadb494d36a59392f49935ca29bb5216aef577ed1cdf9455a2a7e916d73bb490427d9d0ff086b9252b7e10254
        PROVIDES mingw-w64-i686-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.28-1-any.pkg.tar.zst"
        SHA512 4af35d0b29b78bca9b7059eaedad0e5a131b0b6f8c7a6507b58a6de1caff56ebe4c67ebfae232bd284cd877be0a1572a2dce3e1e6f1fb6a39ef5fd74115d75f0
        DEPS mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.19-1-any.pkg.tar.zst"
        SHA512 5adbd5fca1c4f22a54763b3fc8d8fa2a6348c43051433d5d05f1788ad15625ebd979d7289e76e96813ee710f3a39ccd56125e9d6e1bba406344cedaa18241d20
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 9fd2c9e60f3af58849df987cb7e2d6ad376fedf19e33cf180ad27f86719adc359cbb4a5fb53cab5a60d73a74e7fa22f39ccde978868cda13be402d1f0868be4d
        PROVIDES mingw-w64-i686-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.4.1-1-any.pkg.tar.zst"
        SHA512 1452015ec5181bfe60d4c5fa06892cd2d4d940ea706b26d1ce8b1aeb1d48eb8e72530a16a6cfa345ad35a3ca0d8d01e1a7cced4e4ec8c60261cd199b3d2c0636
        DEPS mingw-w64-i686-gmp mingw-w64-i686-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.2-3-any.pkg.tar.zst"
        SHA512 74b3593a3e7dd583515b37e6fe8f0b97f1346d4bbeda78fb2c968b177b50ae3efad932d93804909c4a9dc45cf13eb18f475a5e2dca1e8dbc9be434c39318d424
        DEPS mingw-w64-i686-cc-libs mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-20260815-1-any.pkg.tar.zst"
        SHA512 aa91e3e6869d42de8561f61412a06c8921bd9474e7b12664d4257d95b5be31a9b29e8ef4bb43f1ef4a3e5ecbb9f7dd2a9f32a653be0734b982aa811de175c879
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 9278376c3abcad62fff33e32b6440ccdd1581307adade07ecd98a8fa9027f1338019abf1bfe209ba65cc5fdabbcfdfe94c9baabcc04f54e9ed7ace813962019f
        PROVIDES mingw-w64-i686-winpthreads-git
        DEPS mingw-w64-i686-crt mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.3.2-2-any.pkg.tar.zst"
        SHA512 a132d1deec9af8933736d0f2322c9f3826053f74b96385c1ea652f9163febf85f44b27bb33e67845d5722e5b40650496d512e57a1d322a6a7ce7faa341940cf8
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zstd-1.5.7-2-any.pkg.tar.zst"
        SHA512 303d80ec36a8c4c2b2fc05e33b4c643a869d8fd2709304ea8b8268b492ad3d797e36ed8c0fd33febc007544cc7607f7d435c2d4a3dfebfe313f718312e2fcc19
        DEPS mingw-w64-i686-cc-libs
    )

    # primary package for x64
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-16.2.0-4-any.pkg.tar.zst"
        SHA512 347ec90867ec1856b2211b8b1485cf2670e7700270ee245f60b89ba013923f1e0b0082f806bf737d123844bd8408749ce255a3ce8ba308d7efb74202db0d4724
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gmp mingw-w64-x86_64-isl mingw-w64-x86_64-libgfortran mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.47-3-any.pkg.tar.zst"
        SHA512 73894d10088e67f4f040c0032a694df225018d8a998187a34db5a217c9a554d1fa9694e0b82a826b1d20be010c5e7c0ea76ab15896246588b6b2d5db551a7b85
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 34573cedbccbea3d2497e9899989575eda6eca9b8c5b052369d3896a95d91f28568a08ef8551bc8c1ffc8bfcf92d060640c66ee964987fe43493f7a47eeed86b
        PROVIDES mingw-w64-x86_64-crt-git
        DEPS mingw-w64-x86_64-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-16.2.0-4-any.pkg.tar.zst"
        SHA512 f8f48f0e75316e93caf1b1dd6ebdde74cdcb0021e614dedcb9b45b54f73570a39eb608b0b5c97fc4f50effb94e644f02a94892a0c826f3bf898b657aaed1554d
        PROVIDES mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-gmp mingw-w64-x86_64-mpfr mingw-w64-x86_64-mpc mingw-w64-x86_64-libgcc mingw-w64-x86_64-libstdc++ mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 037384998aba866c98a176b5633a2e934c695bab0150c303a845ccb544ac8ef8b28a93e0688739ab4056acbddd075a48da4988ddf16e77a76e5c4b8bcbb5786d
        PROVIDES mingw-w64-x86_64-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.28-1-any.pkg.tar.zst"
        SHA512 f912d8b7260b482536a88df40e0af864ed746f9b86ac03dc70363937a665b157cb2a7d5a35f0ffaab8ff49c27fc37cf6ecef3389e565fab11f1e32cf70f8b150
        DEPS mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-20260815-1-any.pkg.tar.zst"
        SHA512 f2b392065c8d7a073247150c3a7348a8bab3821b60fd1a065ff1de66552f989b6436a237f9dc267c1280e3ceaf830c682321622fc1a1511b19bf3d963495cd0d
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-14.0.0.r426.g4564ee4b5-1-any.pkg.tar.zst"
        SHA512 a0920ed51942e7c05cbc1f559bc42bcc649f9e60557c5bfb90c8e770fa634b72c0fe2d54229d76c3c1648e3bcc615afcde3c07381dec6388c3a20ee16d291bf8
        PROVIDES mingw-w64-x86_64-winpthreads-git
        DEPS mingw-w64-x86_64-crt mingw-w64-x86_64-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.7-2-any.pkg.tar.zst"
        SHA512 14a28ba398ebfb7e7fae5634f7fe848d4e301a732f78df47816dc24e08344948b41b9c519f5eca19df9e89686d0f1daefb0cbf178dc5a7b6bc1f5da63d768b5c
        DEPS mingw-w64-x86_64-cc-libs
    )
endmacro()
