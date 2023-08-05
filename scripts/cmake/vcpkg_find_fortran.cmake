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
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-fortran-13.1.0-6-any.pkg.tar.zst"
                        7eb61f1d9216c3a9e2bd88afaf82c6057eb72f20ff19bc8e5bfef5cbb851247a480887cb2dc27c610e9f9c0e1830683c0c0be9521f252d106068fc3bbf2e13e3
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-binutils-2.40-4-any.pkg.tar.zst"
                        4ebba5195f34f9a3dc67f640f793e4916f0e82680dbba010bb3720faab3a08e1b7fe800959fd523cf250d5bd3ba5df9a07ead4c40c02e89002e4df61d824d7cd
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-crt-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        4705c51aed87b74c32f8ea93f0a5ed2011de10ae1d1111c11b05ac6f1621fb99b204a3eb4d19778701f9378990522e65ae514186489acb14d10cc25007f5715b
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-13.1.0-6-any.pkg.tar.zst"
                        add77dc0d7554316cbcb1042630c03757db92176bccf5b506b51eeccccb13f5c9b0a5bcdfb8cfccb5c4f776c97820f2e4ed1f537f6520f6f3179ee87860a8c1f
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libgfortran-13.1.0-6-any.pkg.tar.zst"
                        e65603558e13bf8135050a014dfe2ab0d0fa34f4f34a4d13996b75a88247f64abf57842f592f590992e531253f68c6b392adb4ce03e41631e81db7ae9eaff2c7
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gcc-libs-13.1.0-6-any.pkg.tar.zst"
                        d85674dc026dae7f79d232b36d731fa147d1644b3bde90f5c529875272bd9cec8012530c84ed2490ee4dc913dd9bda169684d340ba87380b8b4963950b55c7de
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gmp-6.2.1-5-any.pkg.tar.zst"
                        d576eb3457e26d61cd5b12b62734fbf740d26ab4127db033505474bcf4b701e06f2414121931d49b1665c5c95521c42ae08955c12e1a715e22d4c9d9eea42e27
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-headers-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        8e866a3b22039fae102af371e4ea0e75dc6ffe9c89798345e5d334b386c1f48295dd54fcd8e537f30313a72d38da95d8d98cb129a5fa3bff3aa66722e3fa697f
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-isl-0.26-1-any.pkg.tar.zst"
                        2011de9ac6ed85fa4346f9c9b39136854f049a9e21fb2fbd8db066ccf443301a65ab0c7aa7daed6730d5163ca70ebf25fd39209bd5226f2b70f000ce9de0df8d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-3-any.pkg.tar.zst"
                        36ec45b311ac0e281c5272516b2138364b1b1c0db78a83b26218d50c643345fdb3f75bf4935e8520d839c99f2ec4cb72a324017f11a717bdab06f8c243ccb108
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwinpthread-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        60eccb7030039f7a42a6c6377d2cad9957c2f4693ecfa7672417a145fae21a62129475279deece9eb3e892a69a6f3d6d7e10e3fb9deda47e123e3e3d4f610d9d
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpc-1.3.1-1-any.pkg.tar.zst"
                        e2597ccdd430530e98c6c4b34deed4d8d423dad144691e5ebe353f8d3f0fde3ad231347086843e5a97b74b5218bc3994bbd3b65db81a68c7b3fcd02e17e9f435
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-mpfr-4.2.0.p9-1-any.pkg.tar.zst"
                        e9f1f5727989919950958bc82841c7072cc0ba8a50c8781c0953267acc192dc8dfb4fd6bde599eb505ff6dd2ac94e28ac71e46c5e1c839f0546faa2f86c3e042
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        103f8437e13fb2a839c5eb89f49f5888c71f7934771cf3b2dcca46d520277fe7f7d4841c9d415b454a6a581c6d1f806d6be7f614027df0484f2642ef2563e889
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-winpthreads-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        0622f9595709a17c464f2be01b19a40dfb218c36f779e35ef883ae80db26bac4eb2b2ef35d5e87cf5db5a1fe79a8390c586b7248224f468b9f0beadd516cf540
                        "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-zlib-1.2.13-3-any.pkg.tar.zst"
                        3f4136bbe96025d897848fc30c087cea70c6713684e23a804928bf5957d70f708876a47318ddd9d3841debb57e7f3e550756e3c4e99698f91dd1ab27da837787
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
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-fortran-13.1.0-6-any.pkg.tar.zst"
                        8c72bb5d15fead9559487d14279d802b1948c5a911efdb1cf3908dae8e63c26bd1e539870b7a0bbe73e4229485b66094852c0a49e4f8da8c92a9615885fcfd76
                        # dependencies, alphabetically
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-binutils-2.40-4-any.pkg.tar.zst"
                        2f51c5fbb292df0655c8f30dbbb9891eb40bef1152de68e3e05e1dd614c5b5f91c35547ef737e95d6bc83aa2336a96589a83badb068301d478a09e3f769d0e85
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-crt-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        0016ed126b6d666872796852200af8e5f7e6156986e419bd5a40693ceafae5ce0d3fb341f05ada6640725ee104c4ddc8df295447a5e78bcf67ddcbe26455bdfd
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-13.1.0-6-any.pkg.tar.zst"
                        9b838c1f38ff311645f9ffeb2e129c637c98fec87c4442607c29284ae91964586d702d7cd194f47c730fe0bcb039dbcaf958b89485cd8d7b73de66f15b68fd1c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libgfortran-13.1.0-6-any.pkg.tar.zst"
                        313841c9df8be664fe4bc37c528ebc7aeaf1c828aa561e7014dc329a03a57263cdf3f232021210f749139eac78a7e66c4b367f2a160f9123abe53af41efe8c2c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gcc-libs-13.1.0-6-any.pkg.tar.zst"
                        526c64dcab261e5ed453f3fb455a05e4241f0fec358bc988c46e3f6c3007dec9f9ab9580dbfd3a0b009d606cadc517f58e7f1ff487cfb802b52396b014f36b50
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gmp-6.2.1-5-any.pkg.tar.zst"
                        7d884ef1186bd6942f7a7ace28963aae679bb6c6c77c05f186323c44b11894b80f53203a6fad55a0ae112fec41b4e1a624e67021e5f2f529a7fedf35c2755245
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-headers-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        f5fcce6b2460a35a1d3f22ecd7028e3989cedac948eacb49ccf534418c0cc221f02392aaa62bc137e0298e38c9887642301c7098ef122035ad349f4055d418f9
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-isl-0.26-1-any.pkg.tar.zst"
                        2c715b50807ea2c134784210553d0c725f8eeb1221d64f0510c76f7538098d8400ac1ef329656a2fcb0bda270f9e1d82917d00b9ba11a985ce64ae7c3bf24977
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-3-any.pkg.tar.zst"
                        57221118a6ed975ddde322e0d34487d4752c18c62c6184e9ed77ca14fe0a3a78a78aefe628cda3285294a5564d87cd057c56f4864b12fa8580d68b8e8a805e16
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwinpthread-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        5c8c36bf5b5517f66615aca412570af41e079d2325443051743de0408d7827e24ca9bff38a6dc0c5bb0aa1f5989ebd36eafbd3f593f7e9e766f45c3f1bfb4a40
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpc-1.3.1-1-any.pkg.tar.zst"
                        57b86866e2439baa21f296ecb5bdfd624a155dbd260ffe157165e2f8b20bc6fbd5cc446d25dee61e9ed8c28aca941e6f478be3c2d70393f160ed5fd8438e9683
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-mpfr-4.2.0.p9-1-any.pkg.tar.zst"
                        a247bdc1d1715cd63d3cf026d429811bd11ed000b4047e36b3452d647892136c9f754eb63c692134e856aca129e063cfb409306ff0e766755c51982c9bd4f9ba
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-windows-default-manifest-6.4-4-any.pkg.tar.zst"
                        d7e1e4c79f6c7db3bd97305ff89e407a32d3ce9f2a18083b9674538d018651e889efb6fdef00cc79c78f8c07852eab63d7fc705e9567b1ad5684f0a704adeaf3
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-winpthreads-git-11.0.0.r18.g9df2e604d-1-any.pkg.tar.zst"
                        bd30fa84ebe6ff734534e133c023aff7c86b6931a053296896b0bcccb939d854e47b5a0365878ab94258553fbb4f12b42db2841fb39bb6c739e0e154029ea76c
                        "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.2.13-3-any.pkg.tar.zst"
                        c07bea5fcc78016da74756612827b662b5dd4901d27f3a3390acc3c39b767806f48b09bd231140a40e3cd7aba76e5d869ed18278c720277e55f831f0c7809d54
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
