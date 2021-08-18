#[===[.md:
# vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If not it will switch/enable MinGW gfortran 
                       and return required cmake args for building. 

## Usage
```cmake
vcpkg_find_fortran(<out_var>)
```

## Example
```cmake
vcpkg_find_fortran(fortran_args)
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
)
```
#]===]

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
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-fortran-10.2.0-1-any.pkg.tar.zst"
                        ddbdaf9ea865181e16a0931b2ec88c2dcef8add34628e479c7b9de4fa2ccb22e09c7239442e58702e0acd3adabc920565e976984f2bcd90a3668bf7f48a245f1
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libgfortran-10.2.0-1-any.pkg.tar.zst"
                        150f355085fcf4c54e8bce8f7f08b90fea9ca7e1f32cff0a2e495faa63cf7723f4bf935f0f4ec77c8dd2ba710ceaed88694cb3da71def5e2088dd65e13c9b002
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-10.2.0-1-any.pkg.tar.zst"
                        113d8b3b155ea537be8b99688d454f781d70c67c810c2643bc02b83b332d99bfbf3a7fcada6b927fda67ef02cf968d4fdf930466c5909c4338bda64f1f3f483e
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.0-1-any.pkg.tar.xz"
                        37747f3f373ebff1a493f5dec099f8cd6d5abdc2254d9cd68a103ad7ba44a81a9a97ccaba76eaee427b4d67b2becb655ee2c379c2e563c8051b6708431e3c588
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
                        2c3d9e6b2eee6a4c16fd69ddfadb6e2dc7f31156627d85845c523ac85e5c585d4cfa978659b1fe2ec823d44ef57bc2b92a6127618ff1a8d7505458b794f3f01c
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-winpthreads-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
                        e87ad4f4071c6b5bba3b13a85abf6657bb494b73c57ebe65bc5a92e2cef1d9de354e6858d1338ee72809e3dc742ba69ce090aaad4560ae1d3479a61dbebf03c6
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.1.0-1-any.pkg.tar.xz"
                        d236b815ec3cf569d24d96a386eca9f69a2b1e8af18e96c3f1e5a4d68a3598d32768c7fb3c92207ecffe531259822c1a421350949f2ffabd8ee813654f1af864
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.1.0-2-any.pkg.tar.zst"
                        caac5cb73395082b479597a73c7398bf83009dbc0051755ef15157dc34996e156d4ed7881ef703f9e92861cfcad000888c4c32e4bf38b2596c415a19aafcf893
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-10.2.0-1-any.pkg.tar.zst"
                        3085e744e716301ba8e4c8a391ab09c2d51e587e0a2df5dab49f83b403a32160f8d713cf1a42c1d962885b4c6ee3b6ed36ef40de15c4be2b69dbc3f12f974c3c
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-binutils-2.34-3-any.pkg.tar.zst"
                        ff06b2adebe6e9b278b63ca5638ff704750a346faad1cdc40089431b0a308edb6f2a131815e0577673a19878ec1bd8d5a4fa592aa227de769496c1fd3aedbc85
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-crt-git-8.0.0.5966.f5da805f-1-any.pkg.tar.zst"
                        120c943ce173719e48400fa18299f3458bc9db4cf18bb5a4dda8a91cc3f816510b337a92f7388077c65b50bbbeae9078793891ceaad631d780b10fde19ad3649
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-headers-git-8.0.0.5966.f5da805f-1-any.pkg.tar.zst"
                        dbb9f8258da306a3441f9882faa472c3665a67b2ea68657f3e8a1402dcfacf9787a886a3daf0eefe4946f04557bc166eb15b21c1093ad85c909002daadba1923
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-2-any.pkg.tar.zst"
                        fe48d0d3c582fee1edb178425c6daf619d86362442c729047b3c356be26491164f92be1d87950429d2faca4ed3cf76cb4aafef1af3c87b780eee85ee85a4b4c5
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-windows-default-manifest-6.4-3-any.pkg.tar.xz"
                        5b99abc55eaa74cf85ca64a9c91542554cb5c1098bc71effba9bd36242694cfd348503fcd3507fb9ba97486108c092c925e2f38cd744493386b3dc9ab28bc526
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-zlib-1.2.11-8-any.pkg.tar.zst"
                        46bbf0f28d9faf047221def19e6f94b9556fc6c951cad9c4fb657fde9d15303b9cb64aad11eaa57892cde49eafb43fbe2ec6da6b612449a20ae49dc8233e945b
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-zstd-1.4.5-1-any.pkg.tar.zst"
                        68f431073717b59549ab0fd26be8df8afcb43f3dd85be2ffcbc7d1a629999eed924656a7fc3f50937b2e6605a5067542d016181106b7bc3408b89b268ced5d23
                )
            elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
                set(mingw_path mingw64)
                set(machine_flag -m64)
                vcpkg_acquire_msys(msys_root
                    DIRECT_PACKAGES
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-fortran-10.2.0-1-any.pkg.tar.zst"
                        0de02db791e978ae21577e675ee9676f741336c9a5ceb5614dbdfc793e2c1c4749b394f41362af7b069e970302fddf8c6772ebd8445fe1c360861606b1784b4d
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libgfortran-10.2.0-1-any.pkg.tar.zst"
                        c2dee2957356fa51aae39d907d0cc07f966028b418f74a1ea7ea551ff001c175d86781f980c0cf994207794322dcd369fa122ab78b6c6d0f0ab01e39a754e780
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-libs-10.2.0-1-any.pkg.tar.zst"
                        d17eff08c83d08ef020d999a2ead0d25036ada1c1bf6ed7c02bad9b56840ee5a3304acd790d86f52b83b09c1e788f0cecdf7254dc6760c3c7e478f65882cd32d
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gmp-6.2.0-1-any.pkg.tar.xz"
                        0b22b7363e27cec706eb79ee0c45b5fe7088a5ca69e0868e7366481ed2ea9b3f6623d340cebba0b5ed3d79e4dfc7cf15f53530eb260c6d4057bfc3d92eb8c7bc
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
                        a6969a5db1c55ba458c1a047d0a2a9d2db6cc24266ea47f740598b149a601995d2de734a0984ac5e57ee611d5982cbc03fd6fc0f498435e8d6401bf15724caad
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-winpthreads-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
                        87ae090a8de855de5580f158f4007f88d6dad341429620685dc736be55b1f060487552040327a76003618e214a11c1f8e5105ca2c7abe164908121627449d679
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpc-1.1.0-1-any.pkg.tar.xz"
                        db075a1406690935db5780af293660385f56699881a1b2cd25ab252183643d71d646b0dadf1e34174df8f0744d51ce8b56dccd719e049efcaf9b7e08e80a7ef6
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-mpfr-4.1.0-2-any.pkg.tar.zst"
                        14739667242b8852f0d26547eb3297899a51fd1edafc7101b4e7489273e1efb9cb8422fc067361e3c3694c2afcc6c49fc89537f9f811ad5b9b595873112ee890
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-gcc-10.2.0-1-any.pkg.tar.zst"
                        7a08c7923f688ca8f06d55e1e91b9059a933ee56e27075ea073e6e58ae220310fb5f79869886a61b6987ab08993c9f962a4bfc50b6ea80473e933ce5551f3930
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-binutils-2.34-3-any.pkg.tar.zst"
                        4efd5586c344802110ea0061867469a23571df88529d66a943f86add1287f85ef53b6a9a9b16af2cb67bd09e0760a6f290c3b04ba70c0d5861d8a9f79f0ac209
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-crt-git-8.0.0.5966.f5da805f-1-any.pkg.tar.zst"
                        0142e4a44c59d17380a4fc7b101a2152486781621d5f9f930045b8f9c4bb2c93ea88211e7d8f8f233e0ae09595c6c8bc948ae80b9673f231e715b0d04c8a1e54
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-headers-git-8.0.0.5966.f5da805f-1-any.pkg.tar.zst"
                        b547091a45ea7df8182b627edc9a7c91a23f01c0d4e02634a590c02f24311741cad92ceb67b7e4432ffbe4266f135a5289eb3560cc90ffa5c57612c8537a1588
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-2-any.pkg.tar.zst"
                        542ed5d898a57a79d3523458f8f3409669b411f87d0852bb566d66f75c96422433f70628314338993461bcb19d4bfac4dadd9d21390cb4d95ef0445669288658
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-windows-default-manifest-6.4-3-any.pkg.tar.xz"
                        77d02121416e42ff32a702e21266ce9031b4d8fc9ecdb5dc049d92570b658b3099b65d167ca156367d17a76e53e172ca52d468e440c2cdfd14701da210ffea37
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zlib-1.2.11-8-any.pkg.tar.zst"
                        f40dde3216185e945baf51c29bbf8d1947220593901f982c711a663bb5a303efe434a4f6cf0c885817812fdc81183bcc1a240b96c29abb24a4c83202fd15016e
                        "https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zstd-1.4.5-1-any.pkg.tar.zst"
                        dc2c7289fb206966829c98f6bf4389b423784415532ca3d627a22ae9d756a4fe2faf9844994b3093d814d129d20b2b79897e702aa9569978f58431ea66b55feb
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
