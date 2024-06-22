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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-14.1.0-3-any.pkg.tar.zst"
        SHA512 7caf09bd954aaacaf753f8637fd67ddd386309858ac8ff714d034f14d81203207823db73da70f56ccdd580ea3dc28a340ec6c3efa615444940bea09690429532
        PROVIDES mingw-w64-i686-fc
        DEPS mingw-w64-i686-gcc mingw-w64-i686-gcc-libgfortran
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.42-2-any.pkg.tar.zst"
        SHA512 042c36b8c1d41d0c161d1b461b3a7f24bef46b994878c215d056859987f08277d58908545a41eaa43bc87c3f6afdf14d32f0bdffdb2b7b5b5958b8d1cf1ac9bb
        DEPS mingw-w64-i686-gettext-runtime mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 3e80eef36089c446dc0073f4dff59932a07a260b9e2bd48555b8330c93c038afccf4b503c9e506a24dcc2fff594f11e92711ebdd76eba7f4e9a236feb2555e55
        PROVIDES mingw-w64-i686-crt
        DEPS mingw-w64-i686-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-14.1.0-3-any.pkg.tar.zst"
        SHA512 b94d5e1cbb9583801649fe9534c9feacc56afa912092a44bb4e5523ed9d1d1a16a6fad11ff84aa570288bade0b5bd9009b569f8d846c1eacb44d5444ad2259f5
        PROVIDES mingw-w64-i686-gcc-base mingw-w64-i686-cc
        DEPS mingw-w64-i686-binutils mingw-w64-i686-crt mingw-w64-i686-gcc-libs mingw-w64-i686-gmp mingw-w64-i686-headers mingw-w64-i686-isl mingw-w64-i686-libiconv mingw-w64-i686-mpc mingw-w64-i686-mpfr mingw-w64-i686-windows-default-manifest mingw-w64-i686-winpthreads mingw-w64-i686-zlib mingw-w64-i686-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-14.1.0-3-any.pkg.tar.zst"
        SHA512 4fc130c903ecf2ba64909878d77adf3eeb1a8881720ebde3dd1dd105060fded8c3f19ad591d02688a1f319008aefb6085d98704e65b77858d62f827b229da98a
        PROVIDES mingw-w64-i686-fc-libs
        DEPS mingw-w64-i686-gcc-libs
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-14.1.0-3-any.pkg.tar.zst"
        SHA512 317762938aa41eabc032354a0c3fe04714b703c4bd9ae9a3c712eb35e5c7565dc3e6aaea93637b1ad0706ec99e5dad8007753b5496240f05bdc657b8348a8f9a
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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 25be48775cc4643d6e3a239280b3eed6b764728dfad8d64628d486d2374b8802acc0bd027730cac6056b4ab9584746d295b257171cad6bf31ae1ee96d9dd08f6
        PROVIDES mingw-w64-i686-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.26-1-any.pkg.tar.zst"
        SHA512 2011de9ac6ed85fa4346f9c9b39136854f049a9e21fb2fbd8db066ccf443301a65ab0c7aa7daed6730d5163ca70ebf25fd39209bd5226f2b70f000ce9de0df8d
        DEPS mingw-w64-i686-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-4-any.pkg.tar.zst"
        SHA512 7b8c0861fe404e6a94e19e2f539c8b8eebd438ebd453960655478109c22cb1ace689031a5fc2ed2430df7bb204f83989726ea3552a58f7c323b150bb3f117578
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 0c6b32bdaeb7ed81ca126d76588758b460b6471d4d44d5087a5bb72f3eab4bc4a392ab0a5036646a3cbab4f23ca7c209b9049f86368675efe4edeed41573fd10
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
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 7cbcd80767e95cbaa30c9b0ae698dce1fae10245247f8e9c94f530cc4e3fd1f41d1964f426253030a4b336a9295733fff68781a521bbaf16f11adea0268b4ab7
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
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-14.1.0-3-any.pkg.tar.zst"
        SHA512 868b9557449acfa3918f3cb5b2253132899fd16f091c7fdf17e1a0ef0d1775596cc1eb7ea01c256c787ef5f49f93493ccf9eb9ffe33f4df8b7a06d8d4bc039dd
        PROVIDES mingw-w64-x86_64-fc
        DEPS mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-libgfortran
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.42-2-any.pkg.tar.zst"
        SHA512 8aa4cda10a8bd06829c9c99e2653eb5821ba42ed4d433c66ddcd8f1477a6e7f02696f00f3e66839b6feb0a9105bfc509ca4f6b231d1601e78e8b2b4f026b6dac
        DEPS mingw-w64-x86_64-gettext-runtime mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 630cd55570ebb70c9f373f870860df0e2b7933563a8518ef4d91e81e61b3b7b74a0e7f129e2ef887e601dfbd1eed04623e9d463e8787b5e260839b5c431f5342
        PROVIDES mingw-w64-x86_64-crt
        DEPS mingw-w64-x86_64-headers-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-14.1.0-3-any.pkg.tar.zst"
        SHA512 68644432398ca947bc4e487da3a60ff1726280aa32bde2a52319b1440bf30e992ef8ffa6ba649964471a6dbf17c3f5efc95d8d2270d1d29d6a583beec1b53e79
        PROVIDES mingw-w64-x86_64-gcc-base mingw-w64-x86_64-cc
        DEPS mingw-w64-x86_64-binutils mingw-w64-x86_64-crt mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-gmp mingw-w64-x86_64-headers mingw-w64-x86_64-isl mingw-w64-x86_64-libiconv mingw-w64-x86_64-mpc mingw-w64-x86_64-mpfr mingw-w64-x86_64-windows-default-manifest mingw-w64-x86_64-winpthreads mingw-w64-x86_64-zlib mingw-w64-x86_64-zstd
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 650511469770aea67fb26ad4f72943268ef7b8783890734a15d4aa6b843a4ae79bab68813eb563b467f66d6f382422bdf9a8d18f5694d6b4b58b7fa8c99bc25e
        PROVIDES mingw-w64-x86_64-headers
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.26-1-any.pkg.tar.zst"
        SHA512 2c715b50807ea2c134784210553d0c725f8eeb1221d64f0510c76f7538098d8400ac1ef329656a2fcb0bda270f9e1d82917d00b9ba11a985ce64ae7c3bf24977
        DEPS mingw-w64-x86_64-gmp
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
        SHA512 d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-12.0.0.r32.gf977e1c38-1-any.pkg.tar.zst"
        SHA512 cd238db5b3988ae1099f87399a972108c9a632a9c961d4e98de6e894e5a05eeb1d0611426b621102d3585794effd4f0ade0a09abb02f38eabe97cc319908c000
        PROVIDES mingw-w64-x86_64-winpthreads
        DEPS mingw-w64-x86_64-crt-git mingw-w64-x86_64-libwinpthread-git
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zstd-1.5.6-2-any.pkg.tar.zst"
        SHA512 3cdf7056c7b477fec0333871c3b220f610706d74b8ae0325b8f84daa6e441cc96db0073a08fd56b9f42932d787c7356823ca11434556e2fec46f17898c432f5d
        DEPS mingw-w64-x86_64-gcc-libs
    )
endmacro()