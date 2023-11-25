function(vcpkg_find_fortran out_var)
    if("${ARGC}" GREATER "1")
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra args: ${ARGN}")
    endif()

    vcpkg_list(SET additional_cmake_args)

    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    include(CMakeDetermineFortranCompiler)

    if(NOT CMAKE_Fortran_COMPILER AND "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" STREQUAL "")
        # If a user uses their own VCPKG_CHAINLOAD_TOOLCHAIN_FILE, they _must_ figure out fortran on their own.
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Using MinGW gfortran!")
            # If no Fortran compiler is on the path we switch to use gfortan from MinGW within vcpkg
            if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86")
                set(mingw_path mingw32)
                set(machine_flag -m32)
                vcpkg_acquire_msys(msys_root
                    NO_DEFAULT_PACKAGES
                    DIRECT_PACKAGES
                        # root package
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-13.2.0-2-any.pkg.tar.zst"
                        4820fbd4d927f8378a6e801496364c9bba2e48527a6bff547d6d0b8e248a794f960220827cfb99441eaf97395a18a557cdbb9a337dc52f6af44d4bc32397916b
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.41-2-any.pkg.tar.zst"
                        2f67e5caf6d5ee8995772831bf6cf7a8a24a824d36cc3cb0d4c147bb10261b67f0ec611ef9dc6f9f9642be596973ed04802322101b05afa8f41fcbe3f63bc1c7
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        0f96ab127d9579728d608057a9940682fd6ccfdb153750e8a9b132bac8ee2e87fa6a406b389f319eec2ca7317e97c0dc604f7b1d0697bf07f9c3fb54b2732966
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-13.2.0-2-any.pkg.tar.zst"
                        267f853849351280a5942ae4931df43269c6ea58fcf90fce729766179d318ae75f9cf54da41987e6a5e6f3ef6ad0045085722f01336aab981b275ec17a0602f2
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-13.2.0-2-any.pkg.tar.zst"
                        207c72336fcf965e52e73eae823b8407d0ffa53d8f4e3c544bd4bfa8bd6fb17a6413007d02d71eac911bee48735a0889fbe7a50fa7430725f401ca255ca2b0a6
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-13.2.0-2-any.pkg.tar.zst"
                        6d09c0868c96a532dd1e1dc92e2b5e3c5776af21bd13e6c6de90afc1f705028525550bf909c0d8e80017819cd71acfe64f56838df3d13e571ed4adc7b66b0fae
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
                        4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        c17e1642d1dc9e8d9eca93834bcd48c5052ebe3e50b29b3469fdbc48178dae6ddd852641c55cb1a05a95757f54ba01f6a176ff546ff994ceae36e08b80c3ee79
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.26-1-any.pkg.tar.zst"
                        2011de9ac6ed85fa4346f9c9b39136854f049a9e21fb2fbd8db066ccf443301a65ab0c7aa7daed6730d5163ca70ebf25fd39209bd5226f2b70f000ce9de0df8d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-3-any.pkg.tar.zst"
                        36ec45b311ac0e281c5272516b2138364b1b1c0db78a83b26218d50c643345fdb3f75bf4935e8520d839c99f2ec4cb72a324017f11a717bdab06f8c243ccb108
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        3560884d47d07bbacb640774a3f293c8204f652272f4f0041f6be4eb3c20f6ad410248854367b966fe4aa7defa918af654e0f22e765b29b312c80c901b9c24c2
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-2-any.pkg.tar.zst"
                        936acdedea20b9892f90ebdb0b75250d1ed3d65487316ee986b8672683b01d4e1f2922387f18ea8d6befb71bf273995d4940ff55b645d07996c98bd50c9382ae
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.1-2-any.pkg.tar.zst"
                        0de842b6c3b68c0f743aa4d4a08ca2c9c3f1a1cb426950365e885a55add3966eb545a0634177857e077545ae97950acd49613768bdc13305f08041637e27f8f6
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        095dd47d97599247b6d369bc251a2e4028f072d0c04c6964e30dbf7c3bcbfe3bcc27572a9d100a280bc1106ab721dbb11897bd6482f6cd1f6038d9c07be30a7f
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.3-1-any.pkg.tar.zst"
                        76866c1f2e4f7589473784f1d25938ad5c2a3adc5a2f63d448053b45c40af83f1fe6f5a2dd79ca0dbc96cf9886a1414163b2983f8c3241252f6ca794e872461f
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zstd-1.5.5-1-any.pkg.tar.zst"
                        415be9f2ef78d72109f5888c31248b328ba96f1e2472d488bf45da4fe969875e0e3020a77ceb10cd885f50a18954105e06ce9d122d8c47dc9848944ea71ac49c
                )
            elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
                set(mingw_path mingw64)
                set(machine_flag -m64)
                vcpkg_acquire_msys(msys_root
                    NO_DEFAULT_PACKAGES
                    DIRECT_PACKAGES
                        # root package
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-13.2.0-2-any.pkg.tar.zst"
                        29d4122e078b6d6b2468682a9fa46d1b6196cb014673f1addb6ba09f4fb90c6b4d5f94863b3e5924f4f5a6df3e74024aee1534c6782fc5d10de1022dcf8a3012
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.41-2-any.pkg.tar.zst"
                        86fb9c1857c696b93d950fc63156aa2a67af9da1aec15329dcc31846bf46e6bcb1c394d253899ca24a223e571f608d2397b6131c60c2b7e0a3cbb79e48f43f4e
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        d46ceb9f10b146cba6a916c684e6e6a53fe36f4b8d894be22c9958bb9f0368a09482b08f97e0a2ffca0939dc7b8244f9a9f3732e7af76ce0037e92ef7f96d38f
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-13.2.0-2-any.pkg.tar.zst"
                        19db5d64d5ffeafd482106ef23b06856f7e6b9bdd119c345d2e814816d409f0d7d92d35f237eb18ca962ec492b1a3d911412ec50e744917eda1783b4e26083f0
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-13.2.0-2-any.pkg.tar.zst"
                        206eb7c19060b13286be4966611fe30d4c8a3e17df42aa9ebc5a18da384f16ad149504721b89c615c3cd1579f6744932ea0578ae3c16479472d70ce1a2441e30
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-13.2.0-2-any.pkg.tar.zst"
                        28965ec13cd1006955c7182589d0896f92b7eb29c7d42434fcdc9b93450b51f32b4ce28dc830700e3aa735133facb6db6808db2ac0fae494d601cf3f4a7739e2
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
                        38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        f5176ffef5639add3672324da289b3b2a9a2d52168197007c9ac6a32b4c26c470b2dc894993f11aa96399b4b97f9d1c32d7270022e0dc0f625195d71c8508b09
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.26-1-any.pkg.tar.zst"
                        2c715b50807ea2c134784210553d0c725f8eeb1221d64f0510c76f7538098d8400ac1ef329656a2fcb0bda270f9e1d82917d00b9ba11a985ce64ae7c3bf24977
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-3-any.pkg.tar.zst"
                        57221118a6ed975ddde322e0d34487d4752c18c62c6184e9ed77ca14fe0a3a78a78aefe628cda3285294a5564d87cd057c56f4864b12fa8580d68b8e8a805e16
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        d8e1032fa82283bc1acab5aa1273a94f11ce42ac34c9c656b11acb2e06a400cc15a9fee9f97d99f7c11803d66948c6840051ef7a6a8d9ba1d1cb0d5cb2682cef
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
                        3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.1-2-any.pkg.tar.zst"
                        03a727e1622b09ed0b6e0cb93a6b1040c31c9504c3f14bd1a2e12b8293153609796bc99882393b343c4d96e45f402f847317a3a65212b972ff96a964e5e52815
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-11.0.0.r404.g3a137bd87-1-any.pkg.tar.zst"
                        5d63760987204badc7401a79a5431624a5d3cfafdaab513c194445a0610960915e57162f816560cc46b088de6fe8ad6e5021b0fb8e8462f86bd28f504a0f80ee
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3-1-any.pkg.tar.zst"
                        21191eead4133b5c329ca3e6d1a1b9f724680ddead111ff1f9f544c844a8c66ed8739b19a9f0253f61ce1d40feb0e5354cf692ee5840e0053826996d6cc2ab5a
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.5-1-any.pkg.tar.zst"
                        bc03e39ac48f40e53e2cbff9d48770d8267793608aa6698ddd01371872544e2c023f4be68c638aa349a4c006b6967ac9bf45ce927cf4e4a156c39fa7cb8c27d1
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
