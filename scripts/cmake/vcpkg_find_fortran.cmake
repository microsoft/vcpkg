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
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        f2139563dc2a7735a7596a50dd1dc8403e879726aafff6dd761f7ca4ee427be0323f124f3627655d2962f83bed89d84f0f05517c1a0d2e39f27ebce9289f4779
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-13.2.0-2-any.pkg.tar.zst"
                        267f853849351280a5942ae4931df43269c6ea58fcf90fce729766179d318ae75f9cf54da41987e6a5e6f3ef6ad0045085722f01336aab981b275ec17a0602f2
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-13.2.0-2-any.pkg.tar.zst"
                        207c72336fcf965e52e73eae823b8407d0ffa53d8f4e3c544bd4bfa8bd6fb17a6413007d02d71eac911bee48735a0889fbe7a50fa7430725f401ca255ca2b0a6
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-13.2.0-2-any.pkg.tar.zst"
                        6d09c0868c96a532dd1e1dc92e2b5e3c5776af21bd13e6c6de90afc1f705028525550bf909c0d8e80017819cd71acfe64f56838df3d13e571ed4adc7b66b0fae
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
                        4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        d396820e805a8b7835405a9a16f87182b5e51b64bfa2138ffda76e5b6407936b8efde4b0e66b52470219dc3a02930a3ab31d7380351dbc246cd6357678c02870
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.26-1-any.pkg.tar.zst"
                        2011de9ac6ed85fa4346f9c9b39136854f049a9e21fb2fbd8db066ccf443301a65ab0c7aa7daed6730d5163ca70ebf25fd39209bd5226f2b70f000ce9de0df8d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-3-any.pkg.tar.zst"
                        36ec45b311ac0e281c5272516b2138364b1b1c0db78a83b26218d50c643345fdb3f75bf4935e8520d839c99f2ec4cb72a324017f11a717bdab06f8c243ccb108
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        8c48bbf9038d1e0d9d91faab966c4ee97fe25c1d32a490c0aefbd7d264f97123349fb1394c59369490c1b15e9c3a4a1b21b638e0f02b6320ce2b58571b73595a
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-2-any.pkg.tar.zst"
                        936acdedea20b9892f90ebdb0b75250d1ed3d65487316ee986b8672683b01d4e1f2922387f18ea8d6befb71bf273995d4940ff55b645d07996c98bd50c9382ae
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.1-2-any.pkg.tar.zst"
                        0de842b6c3b68c0f743aa4d4a08ca2c9c3f1a1cb426950365e885a55add3966eb545a0634177857e077545ae97950acd49613768bdc13305f08041637e27f8f6
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        400bb1765216968fe723e711225e840e739ad4acc648ff6bbe3f3e67e84bf640d64321f94b75e321ae7699da21a5ab9a60abbc6274bfcd87f7a0fa8bff42d485
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
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        35168b066e48f0cb28c9d9c936cdb27b4192195f6ee8d12991273fafd3ba5ab4dbeea6ec11a2f8c3fb4290a0dc99e502a983f18914e7db3e092ec6a81f5558cf
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-13.2.0-2-any.pkg.tar.zst"
                        19db5d64d5ffeafd482106ef23b06856f7e6b9bdd119c345d2e814816d409f0d7d92d35f237eb18ca962ec492b1a3d911412ec50e744917eda1783b4e26083f0
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-13.2.0-2-any.pkg.tar.zst"
                        206eb7c19060b13286be4966611fe30d4c8a3e17df42aa9ebc5a18da384f16ad149504721b89c615c3cd1579f6744932ea0578ae3c16479472d70ce1a2441e30
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-13.2.0-2-any.pkg.tar.zst"
                        28965ec13cd1006955c7182589d0896f92b7eb29c7d42434fcdc9b93450b51f32b4ce28dc830700e3aa735133facb6db6808db2ac0fae494d601cf3f4a7739e2
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
                        38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        376f4514d14e20a999627e0213b9d9bb26ca40ccc4057d9c30f8ef8e7caae97c9479199cbee7cf3a1d89a9b5d08ff570583047a36cdea59b5e9c821fb81cc993
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.26-1-any.pkg.tar.zst"
                        2c715b50807ea2c134784210553d0c725f8eeb1221d64f0510c76f7538098d8400ac1ef329656a2fcb0bda270f9e1d82917d00b9ba11a985ce64ae7c3bf24977
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-3-any.pkg.tar.zst"
                        57221118a6ed975ddde322e0d34487d4752c18c62c6184e9ed77ca14fe0a3a78a78aefe628cda3285294a5564d87cd057c56f4864b12fa8580d68b8e8a805e16
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        9689e530aa24c42de52b5bdc8ee12cacd92ceb622a1c3b1e310441815ac77eca896883aa36b4b3fbd945b8eef46c6a34ae9cf63f97fd6425ce8547d47cdb5689
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
                        3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.1-2-any.pkg.tar.zst"
                        03a727e1622b09ed0b6e0cb93a6b1040c31c9504c3f14bd1a2e12b8293153609796bc99882393b343c4d96e45f402f847317a3a65212b972ff96a964e5e52815
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-11.0.0.r198.g93ca95b32-1-any.pkg.tar.zst"
                        40a45fddffbedf3654ba4cafc402cf92bfe34806af9cb25d52263c9a583bbd4a6dc37e32ea9d6d0f22a6e4880de6c1e9f271c92654f3f3a96ca565f21c22ca29
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
