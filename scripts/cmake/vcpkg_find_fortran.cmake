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
                    DIRECT_PACKAGES
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-fortran-11.2.0-8-any.pkg.tar.zst"
                        9337dafdeb4f5eaf41bf13441c345b999dd0561b4fc757a67b4e362c3e0afea5828cd68b35d2823c545d74ea81b2c34bd1624f97817690a2931f3a890b5273bd
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libgfortran-11.2.0-8-any.pkg.tar.zst"
                        3e6396eb4dcbe730bb63f4534e25b654008be49f0e113cf34cfb640dba3f67b508a6f5c78f7ab1cc57686936e709bc37a1fdbc20df5ee17fd708a21c1b844af4
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-11.2.0-8-any.pkg.tar.zst"
                        bdf253bb627cfc108407ea0d1f5fc643da0b229a8f7fcc346fcdf7709e0ffbf8d1f75bdea755116c6b30834d1c764496a23c0546ef1048075d312136c6ebe9d9
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.1-3-any.pkg.tar.zst"
                        10787443380a89a3491596946354645899daad07bc159ffcee96243cb51637dfbc163d52751ffd14682b66be8fd65c0379c642df16132f16a80709c4af921bac
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        c89c27b5afe4cf5fdaaa354544f070c45ace5e9d2f2ebb4b956a148f61681f050e67976894e6f52e42e708dadbf730fee176ac9add3c9864c21249034c342810
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-winpthreads-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        85980183879da0d0ea74b9ad1fdfb09e5ed9d2e2212877d47d0f621ce721566e205be0b1913a643d0a95b256441e0bafd803fa9c848a8203dffd7d72109e32c2
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.2.1-1-any.pkg.tar.zst"
                        f4cda83c26bf4225a8c387e0710ea086896e9c89e7863b9a2947982636664b64ffa880cbddfe6d85f8cf7cb3be18296b04874026cdf8b1b702a2820dad135ba4
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.1.0.p13-1-any.pkg.tar.zst"
                        038a1cc6bb080d415b9fc19965a1f1c9419f5c42023e29c87f97b4f630c152602abb706036aa3e0f02e337e9d7ab3a43bd7b1234b3775a43ffceb348e79bac1a
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-11.2.0-8-any.pkg.tar.zst"
                        a6183f0fc80c2e37316b6eb60fdbdccc30b865053dad270c9c96e93cd6fdb2af28a75f981ac1de2fdc22a47494cdb54b8d41d4ecffdf1b1d3a54e85437c20dcf
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-binutils-2.37-4-any.pkg.tar.zst"
                        1c2fbb8b94778c562aed01010c06c804d1cc2c446837879e4f1187470259adaecd86699b084c69e254d98201333db69a55126ea2cd0c188e55c9af849c37315a
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-crt-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        495834d72313021b7553d92a897932f5efc66a0f6f79ebeec574ecd7ddd23e0eed9aacb32601007606abb10b44ba7c7c1ccf6d3437a4338839b2d7b1792327f9
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-headers-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        7959ae9267306c862b8b23be2ab21498f6e7890c936feae3ec9cf5607434e87e446f7c75ff7bd975f23aa24eb1c23d6068957f6af4e8c358f5f4861db64248b8
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-2-any.pkg.tar.zst"
                        fe48d0d3c582fee1edb178425c6daf619d86362442c729047b3c356be26491164f92be1d87950429d2faca4ed3cf76cb4aafef1af3c87b780eee85ee85a4b4c5
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-windows-default-manifest-6.4-3-any.pkg.tar.xz"
                        5b99abc55eaa74cf85ca64a9c91542554cb5c1098bc71effba9bd36242694cfd348503fcd3507fb9ba97486108c092c925e2f38cd744493386b3dc9ab28bc526
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-zlib-1.2.11-9-any.pkg.tar.zst"
                        3e461e835641a2a755a42221011871f8a1ed5fa4b6b23c74db286e29bbcfa2fcd30d4a7c41216728df62c9131dbc1e554720da633ed6b2ba3d6f2b6d5d50a300
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-zstd-1.5.2-1-any.pkg.tar.zst"
                        8e27911a2a5884faa95e1c55058ca15f233d432ed8aa607b04a019758aa21f1357bd5de5ce8709fa47f4fbed6eb00fdfd94e7e2d82023bbc1f1653e95f439e0a
                )
            elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
                set(mingw_path mingw64)
                set(machine_flag -m64)
                vcpkg_acquire_msys(msys_root
                    DIRECT_PACKAGES
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-fortran-11.2.0-8-any.pkg.tar.zst"
                        d56483e090f86410b87526dda7774e010d0bd6beda97edcaeb1dead1128fd5ad870bc761a8a190759c48d58c2526b6975fb849f9c03a6be193741a0fd0bf2812
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libgfortran-11.2.0-8-any.pkg.tar.zst"
                        8537b55633bc83d81d528378590e417ffe8c26b6c327d8b6d7ba50a8b5f4e090fbe2dc500deb834120edf25ac3c493055f4de2dc64bde061be23ce0f625a8893
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-11.2.0-8-any.pkg.tar.zst"
                        2481f7c8db7cca549911bc71715af86ca287ffed6d673c9a6c3a4c792b68899a129dd959214af7067f434e74fc518c43749e7d928cbd2232ab4fbc65880dad98
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.1-3-any.pkg.tar.zst"
                        d0d4ed1a046b64f437e72bbcf722b30311dde5f5e768a520141423fc0a3127b116bd62cfd4b5cf5c01a71ee0f9cf6479fcc31277904652d8f6ddbf16e33e0b72
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        a2c9e60d23b1310a6cec1fadd2b15a8c07223f3fe90d41b1579e9fc27ee2b0b408456291a55fad54a156e6a247efc20f6fcc247cc567e64fe190938aa3b672e9
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-winpthreads-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        be03433e6006166e5b4794f2a01730cdb6c9f19fa96bd10a8bc50cf06ad389cbc66d44ea3eda46f53c3b2c89e2fc86aec21a372828e9527b24480c87ed88348c
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.2.1-1-any.pkg.tar.zst"
                        f2c137dbb0b6feea68dde9739c38b44dcb570324e3947adf991028e8f63c9ff50a11f47be15b90279ff40bcac7f320d952cfc14e69ba8d02cf8190c848d976a1
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.1.0.p13-1-any.pkg.tar.zst"
                        a1425169c1570dbd736c31d50bedfab88636bf9565376e2da566be67fcc771e6c76f95895f382d81097e7c0580acb42aa49e34dec5d7a868d73a5dc6a7461c95
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-11.2.0-8-any.pkg.tar.zst"
                        26ab2cab684206978a254f1e1595b1ce688e6db12e57ed1d243a5f1b3b21b314f640c7c6fe90eedccb6b9788e1886415ca3290d03b1e71f67f8a99108068336a
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-binutils-2.37-4-any.pkg.tar.zst"
                        f09ea70810fb337d7f3ec673342ab90df511e6af451e273fe88fe41a2f30bd972b79c830b61bb5388743d00a0ba7885503e143987413db5170c4befffef66303
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-crt-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        63d081fedd1f70e8d58670d4d0698535a67f04c31caf02d0b23026ac23fc5064e9423d73c79854bbce41cc99dd0b70e4137af3a609e05cdd867fdcea120d356e
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-headers-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst"
                        05860f2bcfacf54089b750099f9ddc52d9b4b8ae8f69028a198dfb51fab09c37a941ae551e5d361a2a11302d48bd4fa95c44131ddee4c1df5a14f28013398f63
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-2-any.pkg.tar.zst"
                        542ed5d898a57a79d3523458f8f3409669b411f87d0852bb566d66f75c96422433f70628314338993461bcb19d4bfac4dadd9d21390cb4d95ef0445669288658
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-windows-default-manifest-6.4-3-any.pkg.tar.xz"
                        77d02121416e42ff32a702e21266ce9031b4d8fc9ecdb5dc049d92570b658b3099b65d167ca156367d17a76e53e172ca52d468e440c2cdfd14701da210ffea37
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.11-9-any.pkg.tar.zst"
                        f386d3a8d8c169a62a4580af074b7fdc0760ef0fde22ef7020a349382dd374a9e946606c757d12da1c1fe68baf5e2eaf459446e653477035a63e0e20df8f4aa0
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zstd-1.5.2-1-any.pkg.tar.zst"
                        38ec5ca99c5b955bf8a892a3edaf4e18572977736809b7671c554526b13cb4e53d45c5b83e37e0fb7628483ba98831b3203e3e404dac720d5b2ed95cfe4505c4
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
