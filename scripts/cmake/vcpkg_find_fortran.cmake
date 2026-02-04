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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-14.2.0-1-any.pkg.tar.zst"
        SHA512 9de2c2de35519eecdf2b7fb8aed129e1f948663cc0ff8de3ec2da5159de2e9170e25de178a46f600cc1bde8fbbd80354840edf9ad45f22272dd8004a9cfc0e71
        PROVIDES mingw-w64-i686-fc
        DEPS mingw-w64-i686-gcc mingw-w64-i686-gcc-libgfortran
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.43.1-1-any.pkg.tar.zst"
        SHA512 4ed8955e587162acd66ecbb3aeee0b990d3e3d9056139f6636a0d291220d41871848bd1f3069d7f9cf4eac7324760f0a34b38e2301042af9293dc70c12433aa1
        DEPS mingw-w64-i686-gettext-runtime mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 4a8d69cd68944e9439eb531026393663989b7ef62c6f3e8f8b855a74932fc5c09eceeb08acc5ed76781217487040c4f490838ca4cc988474c4d05f7122f69a3d
        PROVIDES mingw-w64-i686-crt
        DEPS mingw-w64-i686-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-14.2.0-1-any.pkg.tar.zst"
        SHA512 6ae166f2b0c1bb63f9c28f1bf6ef6821453eb392bb628ab610a36027a51daae56e983f75f2dedc5e27e46d9024ea14f0f44a436f24f0300877af7455e21015f4
        PROVIDES mingw-w64-i686-gcc-base mingw-w64-i686-cc
        DEPS mingw-w64-i686-binutils mingw-w64-i686-crt mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-headers mingw-w64-i686-isl mingw-w64-i686-libiconv mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-windows-default-manifest mingw-w64-i686-winpthreads mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-14.2.0-1-any.pkg.tar.zst"
        SHA512 d0ca414b78be235ef8a16e1d2c78d7aeb17d09dacf0a4af2cf91bef081790cfc7442ea6dd9109209b81d9074b9c65cafd33f363b9d2186ee2ba663d6bae8fca3
        PROVIDES mingw-w64-i686-fc-libs
        DEPS mingw-w64-i686-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-14.2.0-1-any.pkg.tar.zst"
        SHA512 4c884c3fa9edc042054e5ddb7bf6d9448182263f108ebffcc12f468f39d886ec75faab9ba260531d8d37676db7756e86ea5ea66dc793b4673246444546576f75
        PROVIDES mingw-w64-i686-omp
        DEPS mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gettext-runtime-0.22.5-2-any.pkg.tar.zst"
        SHA512 5835cba4839a154bd850410b7ff8157fe5e3c6744585acf572fb1b045339839d5426643951c210fe58f26eb588c9a4d6492aae1286db8f864d8c9d74ae686dd7
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-libiconv
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.3.0-2-any.pkg.tar.zst"
        SHA512 4a9e0ace05ea441fe6cd69b1b1af4c29e35727069ab1f22d0da7febc7aaba219502b5b4dea8b1aa070cb2c8b731da112429c3339fd03fe77828d9fa262b4a818
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 5d2c83f6c5bc8b19154c60508ff127ddd7c8b220ece335c9178c63a34b43630cc68dfa007be38a736052dd76e0c2d42ec57a3cfe06dd46cf5a963667385acd83
        PROVIDES mingw-w64-i686-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.27-1-any.pkg.tar.zst"
        SHA512 070e87552aa0ce77bb9db3b6104c7a3b0d9b5f3515dffc5d03d586693661a9c4681d54ffa6209203bdd568cf111ecae2b26df7472cf40144d6537d655d01b178
        DEPS mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-4-any.pkg.tar.zst"
        SHA512 7b8c0861fe404e6a94e19e2f539c8b8eebd438ebd453960655478109c22cb1ace689031a5fc2ed2430df7bb204f83989726ea3552a58f7c323b150bb3f117578
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 3ea114a921a8bc10fcc4541b95a50280ec6ecf1ac605a3042f9d74e887c216d5c575621900ed1d4ee84c3e71b32ea16c6e4a7912279c0aef0966f230ad912c32
        PROVIDES mingw-w64-i686-libwinpthread
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-2-any.pkg.tar.zst"
        SHA512 936acdedea20b9892f90ebdb0b75250d1ed3d65487316ee986b8672683b01d4e1f2922387f18ea8d6befb71bf273995d4940ff55b645d07996c98bd50c9382ae
        DEPS mingw-w64-i686-gmp mingw-w64-i686-mpfr
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.1-2-any.pkg.tar.zst"
        SHA512 0de842b6c3b68c0f743aa4d4a08ca2c9c3f1a1cb426950365e885a55add3966eb545a0634177857e077545ae97950acd49613768bdc13305f08041637e27f8f6
        DEPS mingw-w64-i686-gcc-libs mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
        SHA512 103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 b0b06d20bbb2115ef3e19e27f906eca5aba3847ea6a39b234b55e71b231bf32ce401fe9a14bd4729dab06e4cf103469b868ee55f80fb9ca6655877d0bcb513fe
        PROVIDES mingw-w64-i686-winpthreads
        DEPS mingw-w64-i686-crt-git mingw-w64-i686-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.3.1-1-any.pkg.tar.zst"
        SHA512 881cf37f59bfbc3d8a6a6d16226360b63cf3d5abc82bb25fa1d9f871aa3e620fa22a8ae6b0cec619633d08550b72ad289f16b75d5819e3e117de0607125b0140
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zstd-1.5.6-2-any.pkg.tar.zst"
        SHA512 bc25f705ed77f3bdbc31ef6870d9cfe4a9e78cb62bc6938f326fb91ca30b9594bb73f2c23ae08532d1cd81b69ed9a0f56e1408454cd3c04204d4ead8d7c67764
        DEPS mingw-w64-i686-gcc-libs
    )

    # primary package for x64
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-14.2.0-1-any.pkg.tar.zst"
        SHA512 4fdcc70f8620e9963391b09d9a9d26bc7af72ae74630f67706115492085a03288865de0cb51b84ccb9eacac502d0030aeb024cabb2b78d24a3473315abd86bc3
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-libgfortran
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.43.1-1-any.pkg.tar.zst"
        SHA512 39bf1d334d6618be851b1acf59ea1f9ef282d6cc22e9d60d40d37730a936b2226e5cfd9f4a9d5c7cd4cf0e3c314cdef6f4eecff62f2150533b5d70a50cf31e41
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 6c2abf10485e027947b5cf108e9299c57f20e56a9f236125bdaa1ee6074e6258e8296b6f4c297ae6a1b9c3c21e7d1d36aaf2579ab34530e499a4a54f8216d2f4
        PROVIDES mingw-w64-x86_64-crt
        DEPS mingw-w64-x86_64-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-14.2.0-1-any.pkg.tar.zst"
        SHA512 bbf70beb6953e0a076d55e577d195fbde1e00132695464e6c1769b8f9d1580f0469a696e5dc1f8bc496a3a62ed24009637b958a5ae250576d333098c4b67f9e3
        PROVIDES mingw-w64-x86_64-gcc-base mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-libiconv mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 a965625929e3e983df89aadf8da9652776519ffc1690775588619e4debe9743a1f0b004a79980baec3a3a020bd777fb85f901c167ea8364acd15a23c5e91b67a
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-12.0.0.r351.gcdf6b16b8-1-any.pkg.tar.zst"
        SHA512 b11a36b0624d651c2484e5baa06a1a5217e96361a19678da96ddd3e4b00d29cdefe4f76032ee8a55442ac49edd6c9609bc26651f9c6e32f8f8e169417da2c763
        PROVIDES mingw-w64-x86_64-winpthreads
        DEPS mingw-w64-x86_64-crt-git mingw-w64-x86_64-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.6-2-any.pkg.tar.zst"
        SHA512 3cdf7056c7b477fec0333871c3b220f610706d74b8ae0325b8f84daa6e441cc96db0073a08fd56b9f42932d787c7356823ca11434556e2fec46f17898c432f5d
        DEPS mingw-w64-x86_64-gcc-libs
    )
endmacro()