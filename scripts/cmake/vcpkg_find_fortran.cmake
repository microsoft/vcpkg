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
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-13.2.0-3-any.pkg.tar.zst"
                        3f30692ebdbfa10d55f978ef05a8b8ae9b194d57f4e05dded6d4159186a62848109dabf4448b12d2b6fc734a19f61b47f3d8e25efb3bb3c318e9c27cd8d629fb
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.42-1-any.pkg.tar.zst"
                        9f26be2ad7ff05e38c849e6c722eec817328d8604c753fbb6cc8e54bc8ae638a97beb59fc144fdd10cded4f626bb997892bde91d314b18c96ed35c4a4b3bde01
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        5d862184baf667b357d156409552f6b72ad59db53972bdc7bea4b36775ab5c6bfc6cd5697f11be3ec5e58f6f733cc396984ee9cd0aa394cf28536a0a73881826
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-13.2.0-3-any.pkg.tar.zst"
                        4d360d82ce0cef2cf3a5078419465fd502c2b6751f3cadc9bf362c8ef4e4c32a426495d59b8904fd46b2f6fe3feaad7e0f952fcc0152735eed70e083175a303d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-13.2.0-3-any.pkg.tar.zst"
                        6eefe2e1500f80a0484856847bee128b60fb16e54151b1e2b0f6627f8d7820521e9bc1c81f4cbccb68a42029ccee0cbcb72d448a31a780b222268e6be1ae6f97
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-13.2.0-3-any.pkg.tar.zst"
                        342d751cfc33539059d87d3de74048b5ec29139cd2aa757d18781381e5f16878a983dd76f5116ca66d6c7e1a64d1e6be56cc7ff4d5189e46746dbaca03bcbdac
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
                        4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        65c52c5ab7cb0c1238a116dcb730079369e7cf012b98c56a4214e0502045c0370f5e32abe658c190db7b9bcca78699401f7d76e5a457072c6464d067d6a5a8e9
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.26-1-any.pkg.tar.zst"
                        2011de9ac6ed85fa4346f9c9b39136854f049a9e21fb2fbd8db066ccf443301a65ab0c7aa7daed6730d5163ca70ebf25fd39209bd5226f2b70f000ce9de0df8d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-4-any.pkg.tar.zst"
                        7b8c0861fe404e6a94e19e2f539c8b8eebd438ebd453960655478109c22cb1ace689031a5fc2ed2430df7bb204f83989726ea3552a58f7c323b150bb3f117578
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        98c9b36bee8a6aef5f47eae6ecc4577859865aecc7b8fadfccbb5b6a2b6e5a26a3725b6017004004e2468773f1b9d7c0ac59b2940476c5af2f92c158f9c24880
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-2-any.pkg.tar.zst"
                        936acdedea20b9892f90ebdb0b75250d1ed3d65487316ee986b8672683b01d4e1f2922387f18ea8d6befb71bf273995d4940ff55b645d07996c98bd50c9382ae
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.1-2-any.pkg.tar.zst"
                        0de842b6c3b68c0f743aa4d4a08ca2c9c3f1a1cb426950365e885a55add3966eb545a0634177857e077545ae97950acd49613768bdc13305f08041637e27f8f6
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        ff3220bc13e1e1931a013a72d030fa0e8a16c9c920256e33ab8fb0cef4d13c15e03b842e5299b81aaad873fad5a079fb828c65b708d6d79459601a817bc76750
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.3.1-1-any.pkg.tar.zst"
                        881cf37f59bfbc3d8a6a6d16226360b63cf3d5abc82bb25fa1d9f871aa3e620fa22a8ae6b0cec619633d08550b72ad289f16b75d5819e3e117de0607125b0140
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
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-13.2.0-3-any.pkg.tar.zst"
                        8bb2beea8dc3dfa07db0be9294ae057205b122e018bba7c90a840dc73ab894339d91b0b801deff1e7d808d542af79cce211cdd9d16b06fe988a4be99a68a6b05
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.42-1-any.pkg.tar.zst"
                        6e26b960447a825ac08bec8fffc5288fae9c38fab4e065d4f6ebf977ef06fe503a10ad10e2581cb733400b1f41ca5f68b19ba7838a8ef0db132d54683b1ff827
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        656cd64827f9a17fe1c49b6a84430d96ab81b382947aa412ea9c5545121aa1c07f4d342d23c9ddfa1d25e2221d57471c02a2fa1b97796396d5d0802394a0fd72
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-13.2.0-3-any.pkg.tar.zst"
                        75cf55088a3ca09d9a53be7d5f390e26a3686d12b7172a9bf029c81b7055981fbc9ce9c3e353f5e2aa065144a6520bf499900d0cf2eef49dc637e37d68422e5a
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-13.2.0-3-any.pkg.tar.zst"
                        da0902979b2fd1a556d639587caeb24a756bdab29f6179fdb2deac3463bb7c150f13db6b944da2a7ade69d496199b7e8bd22ec1515beb26fab1a01e3b4e6c2bd
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-13.2.0-3-any.pkg.tar.zst"
                        f904ee75196ab63df4b63b84f08bfd5956a178c72fea21fdcf8727f7d70f538b358a546316c4542c36a5c3169f88437426c785ac8e2a99d8eb952be7429216d4
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.3.0-2-any.pkg.tar.zst"
                        38ab150051d787e44f1c75b3703d6c8deb429d244acb2a973ee232043b708e6c9e29a1f9e28f12e242c136d433e8eb5a5133a4d9ac7b87157a9749a8d215d2f0
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        a14e8249b202e31ca071d579fa23b2a668df0fd9fed4480c9071ba8489a5110c0c8fd84264676e1ebc922dfe73c720a9bb7514a7c1bf87aebefa7c99b2be8b98
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.26-1-any.pkg.tar.zst"
                        2c715b50807ea2c134784210553d0c725f8eeb1221d64f0510c76f7538098d8400ac1ef329656a2fcb0bda270f9e1d82917d00b9ba11a985ce64ae7c3bf24977
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-4-any.pkg.tar.zst"
                        dc703b103291a5b89175c3ddf4282c1a40bcd91549c8f993300671b9afffb28559e118a2c665f47a465bd7286b9e3400c29d42761e0189c425fb156b37783927
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        2742d5939e6f677d148f0f07ddc399bf8e4bf3c07f9b90160f20314f1c69e549b9f9d6cbf0df35d7f950d2e09e57c56c0496475cb66f053dcf0bcfdf3bb14bb1
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-2-any.pkg.tar.zst"
                        3fe183d4af3b3935a4394502eab75a8f7b7692f551fd44e54c67935a4691388d23a021ee1147f0345ed27ffe8a8db3e9e7e37caf2348df3413e0acd519c12a0c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.1-2-any.pkg.tar.zst"
                        03a727e1622b09ed0b6e0cb93a6b1040c31c9504c3f14bd1a2e12b8293153609796bc99882393b343c4d96e45f402f847317a3a65212b972ff96a964e5e52815
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-11.0.0.r551.g86a5e0f41-1-any.pkg.tar.zst"
                        f3ed9c1c147d284fb684d54d8b045020047e44fc34159e2841ce13625b58879c5320b6606077db7a362559dea367c39ce794f69f4fd4af9c079baf70336e89c7
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.1-1-any.pkg.tar.zst"
                        1336cd0db102af495d8bbfc6a1956f365750b19d2377fe809e9b26f61a8a6600394e7343677645c5743f4974161535dad5c0503ff50f6126d27bb927754e7320
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
