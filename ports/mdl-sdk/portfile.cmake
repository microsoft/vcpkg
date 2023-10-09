vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Notes on Clang 7 binary download:
# MDL-SDK requires Clang version 7.0.0 previsely as a *build tool* not as a *source compiler* as it is usually used.
# This ports provides CMake instructions to fetch and use it to build this port - and only for this purpose:
# it will not be installed and as such not be usable by any other ports. 
# 
# More details on the why below:
# MDL-SDK supports its own source file format (NVIDIA MDL sources `.mdl`), and can codegen executable code at runtime using its own vendored and modified version of LLVM 7.0.0. 
# Also, at buildtime MDL-SDK also "pre-compile" MDL core libraries as LLVM bitcode directly into its binaries (through generated c array in headers) using this very Clang 7.0.0.
# To have everything working together, we have to use a Clang as build tool which match the vendored LLVM version so that LLVM bitcode can be loaded/linked properly as it is not compatible across MLLVM versions.

# Clang 7 build tool

set(LLVM_VERSION 7.0.0)
set(LLVM_BASE_URL "https://releases.llvm.org/${LLVM_VERSION}")

if(VCPKG_HOST_IS_WINDOWS)
    set(LLVM_FILENAME  "LLVM-${LLVM_VERSION}-win64.exe")
    set(LLVM_HASH      c2b1342469275279f833fdc1e17ba5a9f99021306d6ab3d7209822a01d690767739eebf92fd9f23a44de5c5d00260fed50d5262b23a8eccac55b8ae901e2815c)
elseif(VCPKG_HOST_IS_LINUX)
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04.tar.xz")
    set(LLVM_HASH      fb3dc588137426dc28a20ef5e34e9341b18114f03bf7d83fafbb301efbfd801bba08615b804817c80252e366de9d2f8efbef034e53a1b885b34c86c2fbbf9c28)
elseif(VCPKG_HOST_IS_FREEBSD)
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-amd64-unknown-freebsd11.tar.xz")
    set(LLVM_HASH      d501484c38cfced196128866a19f7fef1e0b5d609ea050d085b7deab04ac8cc2bbf74b3cfe6cd90d8ea17a1d9cfca028a6c933f0736153ba48785ddc8646574f)
elseif(VCPKG_HOST_IS_OSX)
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz")
    set(LLVM_HASH      c5ca6a7756e0cecdf78d4d0c522fe7e803d4b1b2049cb502a034fe8f5ca30fcbf0e738ebfbc89c87de8adcd90ea64f637eb82e9130bb846b43b91f67dfa4b916)
else()
    message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}).")
endif()

vcpkg_download_distfile(LLVM_ARCHIVE_PATH
  URLS     "${LLVM_BASE_URL}/${LLVM_FILENAME}"
  SHA512   ${LLVM_HASH}
  FILENAME "${LLVM_FILENAME}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    get_filename_component(LLVM_BASENAME "${LLVM_FILENAME}" NAME_WE)
    set(LLVM_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/${LLVM_BASENAME}")
    file(REMOVE_RECURSE "${LLVM_DIRECTORY}")
    file(MAKE_DIRECTORY "${LLVM_DIRECTORY}")

    vcpkg_find_acquire_program(7Z)
    vcpkg_execute_in_download_mode(
        COMMAND ${7Z} x
            "${LLVM_ARCHIVE_PATH}"
            "-o${LLVM_DIRECTORY}"
            -y -bso0 -bsp0
        WORKING_DIRECTORY "${LLVM_DIRECTORY}"
    )
else()
    vcpkg_extract_source_archive(LLVM_DIRECTORY
        ARCHIVE "${LLVM_ARCHIVE_PATH}"
        SOURCE_BASE "clang+llvm-${LLVM_VERSION}"
    )
endif()

set(LLVM_CLANG7 "${LLVM_DIRECTORY}/bin/clang${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if(NOT EXISTS "${LLVM_CLANG7}")
    message(FATAL_ERROR "Missing required build tool clang 7, please check your setup.")
endif()

# MDL-SDK

# The patch "workaround gcc bit" works around <bit> included with gcc included with Ubuntu 22.04
# failing to compile as used here, with errors originating *inside* <bit> like:
# [156/1742] /usr/bin/c++ -DBIT64=1 -DDEBUG -DHAS_SSE -DMDL_SOURCE_RELEASE -DMI_PLATFORM=\"linux-x86-64-gcc\" -DMI_PLATFORM_UNIX -DX86=1 -D_DEBUG -I/home/bion/vcpkg/buildtrees/mdl-sdk/x64-linux-dbg/src/base/system/main -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src -fPIC -g -fPIC -fno-strict-aliasing -march=nocona -gdwarf-3 -gstrict-dwarf -Wall -Wvla -Wno-init-list-lifetime -Wno-placement-new -Wno-parentheses -Wno-sign-compare -Wno-narrowing -Wno-unused-but-set-variable -Wno-unused-local-typedefs -Wno-deprecated-declarations -Wno-unknown-pragmas -std=gnu++17 -MD -MT src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o -MF src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o.d -o src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o -c /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main/module_registration_entry.cpp
# FAILED: src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o 
# /usr/bin/c++ -DBIT64=1 -DDEBUG -DHAS_SSE -DMDL_SOURCE_RELEASE -DMI_PLATFORM=\"linux-x86-64-gcc\" -DMI_PLATFORM_UNIX -DX86=1 -D_DEBUG -I/home/bion/vcpkg/buildtrees/mdl-sdk/x64-linux-dbg/src/base/system/main -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include -I/home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src -fPIC -g -fPIC -fno-strict-aliasing -march=nocona -gdwarf-3 -gstrict-dwarf -Wall -Wvla -Wno-init-list-lifetime -Wno-placement-new -Wno-parentheses -Wno-sign-compare -Wno-narrowing -Wno-unused-but-set-variable -Wno-unused-local-typedefs -Wno-deprecated-declarations -Wno-unknown-pragmas -std=gnu++17 -MD -MT src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o -MF src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o.d -o src/base/system/main/CMakeFiles/base-system-main.dir/module_registration_entry.cpp.o -c /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main/module_registration_entry.cpp
# In file included from /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main/types.h:37,
#                  from /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main/module_registration_entry.h:39,
#                  from /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/src/base/system/main/module_registration_entry.cpp:34:
# /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include/mi/base/types.h: In function ‘constexpr T mi::base::binary_cast(const S&)’:
# /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include/mi/base/types.h:356:89: error: ‘bit_cast’ is not a member of ‘mi::base::std’
#   356 | template<class T, class S> constexpr T binary_cast(const S& src) noexcept { return std::bit_cast<T,S>(src); }
#       |                                                                                         ^~~~~~~~
# /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include/mi/base/types.h:356:99: error: expected primary-expression before ‘,’ token
#   356 | template<class T, class S> constexpr T binary_cast(const S& src) noexcept { return std::bit_cast<T,S>(src); }
#       |                                                                                                   ^
# /home/bion/vcpkg/buildtrees/mdl-sdk/src/830ab63109-115b19fca8/include/mi/base/types.h:356:101: error: expected primary-expression before ‘>’ token
#   356 | template<class T, class S> constexpr T binary_cast(const S& src) noexcept { return std::bit_cast<T,S>(src); }
#       |                                                                                                     ^

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF d6c9a6560265025a30d16fcd9d664f830ab63109
    SHA512 d6161a317ca0fd3cf8c782f058fc43765d611b5f6a8e82da736f5164a0e1829a46f75e376715fcb7cb9521406365aa88880ed44235b2bf63899affcc5bd54091
    HEAD_REF master
    PATCHES
        001-freeimage-from-vcpkg.patch
        002-install-rules.patch
        003-freeimage-disable-faxg3.patch
        004-missing-std-includes.patch
        005-missing-link-windows-crypt-libraries.patch
        006-guard-nonexisting-targets.patch
        007-plugin-options.patch
        008-build-static-llvm.patch
        009-include-priority-vendored-llvm.patch
        010-workaround-gcc-bit.patch
        011-fix-python.patch
)

string(COMPARE NOTEQUAL "${VCPKG_CRT_LINKAGE}" "static" _MVSC_CRT_LINKAGE_OPTION)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dds MDL_BUILD_DDS_PLUGIN
        freeimage MDL_BUILD_FREEIMAGE_PLUGIN
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-mdl-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDL_LOG_DEPENDENCIES:BOOL=ON

        -DMDL_MSVC_DYNAMIC_RUNTIME_EXAMPLES:BOOL=${_MVSC_CRT_LINKAGE_OPTION}

        -DMDL_ENABLE_CUDA_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPENGL_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_QT_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_D3D12_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPTIX7_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_MATERIALX:BOOL=OFF

        -DMDL_BUILD_SDK_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_CORE_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_ARNOLD_PLUGIN:BOOL=OFF
        
        -Dpython_PATH:PATH=${PYTHON3}
        -Dclang_PATH:PATH=${LLVM_CLANG7}

        ${FEATURE_OPTIONS}

    MAYBE_UNUSED_VARIABLES
        -DCMAKE_DISABLE_FIND_PACKAGE_GLEW=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_glfw3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_LibXml2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OCaml=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Subversion=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mdl)
vcpkg_copy_tools(
    TOOL_NAMES i18n mdlc mdlm
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
