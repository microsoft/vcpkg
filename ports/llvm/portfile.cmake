include(CMakeParseArguments)
include(vcpkg_common_functions)

# LLVM documentation recommends always using static library linkage when
#   building with Microsoft toolchain; it's also the default on other platforms
set(VCPKG_LIBRARY_LINKAGE static)
set(LLVM_VERSION "6.0.1")

# what about LLVM_BUILD_STATIC?
# llvm dynamic library?
# Not supported on windows
# list(APPEND _COMPONENT_FLAGS "-DLIBOMP_ENABLE_SHARED=OFF")

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "llvm cannot currently be built for UWP")
endif()

function(llvm_download)
    cmake_parse_arguments(PARSE_ARGV 0 VCPKG_LLVM_DL "" "NAME;SHA512;PKG_NAME;EXTRACT_TO;FOLDER_NAME" "")
    if ("${VCPKG_LLVM_DL_PKG_NAME}" STREQUAL "")
        set(VCPKG_LLVM_DL_PKG_NAME "${VCPKG_LLVM_DL_NAME}")
    endif()
    if ("${VCPKG_LLVM_DL_EXTRACT_TO}" STREQUAL "")
        set(VCPKG_LLVM_DL_EXTRACT_TO "tools")
    endif()
    if ("${VCPKG_LLVM_DL_FOLDER_NAME}" STREQUAL "")
        set(VCPKG_LLVM_DL_FOLDER_NAME "${VCPKG_LLVM_DL_NAME}")
    endif()

    string(TOUPPER "${VCPKG_LLVM_DL_NAME}" _pkgName)

    vcpkg_download_distfile(${_pkgName}_ARCHIVE
        URLS "http://releases.llvm.org/${LLVM_VERSION}/${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src.tar.xz"
        FILENAME "${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src.tar.xz"
        SHA512 ${VCPKG_LLVM_DL_SHA512}
    )
    vcpkg_extract_source_archive("${${_pkgName}_ARCHIVE}" ${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO})

    set(VCPKG_LLVM_DL_FOLDER_BASE "${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO}")
    set(VCPKG_LLVM_DL_FOLDER_TEST "${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_FOLDER_NAME}")
    if(NOT EXISTS ${VCPKG_LLVM_DL_FOLDER_TEST})
        file(RENAME ${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src ${VCPKG_LLVM_DL_FOLDER_TEST})
    endif()  
endfunction(llvm_download)

# Install must-have software
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

# Download and extract the main LLVM project
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/llvm-${LLVM_VERSION}.src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
    FILENAME "llvm-${LLVM_VERSION}.src.tar.xz"
    SHA512 cbbb00eb99cfeb4aff623ee1a5ba075e7b5a76fc00c5f9f539ff28c108598f5708a0369d5bd92683def5a20c2fe60cab7827b42d628dbfcc79b57e0e91b84dd9
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle features
set(_COMPONENT_FLAGS "")
set(_COMPONENT_PATCHES "")
set(_COMPONENT_TARGETS "")

foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    if(_feature IN_LIST FEATURES)
        if ("${_feature}" MATCHES "^enable-")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_${_FEATURE}=ON")
        elseif ("${_feature}" MATCHES "^abi-breaking-checks-")
            string(REPLACE "abi-breaking-checks-" "" _featureValue "${_feature}")
            foreach(_components IN LISTS _COMPONENT_FLAGS)
                if ("${_components}" MATCHES "^-DLLVM_ABI_BREAKING_CHECKS=")
                    string(REPLACE "-${_featureValue}" "" _featureName "${_feature}")
                    message(FATAL_ERROR "The feature ${_featureName} is already set.")
                endif()
            endforeach()
            if ("${_featureValue}" STREQUAL "on")
                list(APPEND _COMPONENT_FLAGS "-DLLVM_ABI_BREAKING_CHECKS=FORCE_ON")
            elseif ("${_featureValue}" STREQUAL "off")
                list(APPEND _COMPONENT_FLAGS "-DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF")
            endif()
        elseif ("${_feature}" STREQUAL "single")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_LINK_LLVM_DYLIB=ON")
        elseif ("${_feature}" STREQUAL "clang")
            llvm_download(
                NAME clang
                PKG_NAME cfe
                SHA512 f64ba9290059f6e36fee41c8f32bf483609d31c291fcd2f77d41fecfdf3c8233a5e23b93a1c73fed03683823bd6e72757ed993dd32527de3d5f2b7a64bb031b9
            )
        elseif ("${_feature}" STREQUAL "clang-tools-extra")
            llvm_download(
                NAME clang-tools-extra
                SHA512 cf29d117b6dabcb7a8e5f6dab5016ce5a5c8f475679001a43fd5c935f2c368f37cdef50aae2080a1e4524f647f6d83458d4a5dec5b45d03fb374f463caf7c3f5
                EXTRACT_TO tools/clang/tools
                FOLDER_NAME extra
            )
            list(APPEND _COMPONENT_FLAGS "-DCLANG_ENABLE_STATIC_ANALYZER=ON")
        elseif ("${_feature}" STREQUAL "lldb")
            llvm_download(
                NAME lldb
                SHA512 93ee2efea07276f8838bc2b3ff039cab8c7a1a6965647aaa4dee99f55c6465d5584ed3be87b144e2e32b5acc7db9cec56d89404de764a2f53643ed154d213721
            )
            # Based on https://github.com/llvm-mirror/lldb/commit/b16e8c12330ba21fb45b7d8b1e6ee3f8510b2846
            # Only applies for LLDB 6.x version
            list(APPEND _COMPONENT_PATCHES "${CMAKE_CURRENT_LIST_DIR}/lldb-mi-signal-msvc.patch")

            if (NOT "lldb-python3" IN_LIST FEATURES OR NOT "lldb-python2" IN_LIST FEATURES)
                list(APPEND _COMPONENT_FLAGS "-DLLDB_DISABLE_PYTHON=ON")
            endif()
        elseif ("${_feature}" MATCHES "^lldb-python")
            if ("-DLLDB_BUILD_FRAMEWORK=ON" IN_LIST _COMPONENT_FLAGS)
                message(FATAL_ERROR "You can not compile lldb with support for python2 and python3. Please select only one version.")
            endif()

            vcpkg_find_acquire_program(SWIG)
            get_filename_component(SWIG_DIR "${SWIG}" DIRECTORY)
            set(ENV{PATH} "$ENV{PATH};${SWIG_DIR}")

            # Requires python and swig
            string(REPLACE "lldb-python" "" _featureValue "${_feature}")
            find_package (Python${_featureValue} COMPONENTS Interpreter Development)
            list(APPEND _COMPONENT_FLAGS "-DPYTHON_HOME=${Python${_featureValue}_ROOT_DIR}")
            list(APPEND _COMPONENT_FLAGS "-DLLDB_BUILD_FRAMEWORK=ON")
        elseif ("${_feature}" STREQUAL "lld")
            llvm_download(
                NAME lld
                SHA512 856ccc125255ab6184919f1424372f0f8a5de8477777047e2ab1a131a2ecec0caa9b5163d01409c7c510df9c794f0bc8d65cc904df2baf6462ef53bc163e002a
            )
        elseif ("${_feature}" STREQUAL "polly")
            llvm_download(
                NAME polly
                SHA512 1851223653f8c326ddf39f5cf9fc18a2310299769c011795d8e1a5abef2834d2c800fae318e6370547d3b6b35199ce29fe76582b64493ab8fa506aff59272539
            )
        elseif ("${_feature}" MATCHES "^polly-gpu-")
            if ("-DPOLLY_ENABLE_GPGPU_CODEGEN=ON" IN_LIST _COMPONENT_FLAGS)
                message(FATAL_ERROR "The polly feature can not be build with OpencCL and CUDA together.")
            endif()
            if (NOT "nvptx" IN_LIST _COMPONENT_TARGETS)
                list(APPEND _COMPONENT_TARGETS "nvptx")
            endif()
            list(APPEND _COMPONENT_FLAGS "-DPOLLY_ENABLE_GPGPU_CODEGEN=ON")
        elseif ("${_feature}" STREQUAL "polly-gpu-cuda")
            check_language(CUDA)
            if(NOT CMAKE_CUDA_COMPILER)
                message(FATAL_ERROR "CUDA must be installed for polly feature.")
            endif()
        elseif ("${_feature}" STREQUAL "polly-gpu-opencl")
            find_package(OpenCL REQUIRED)
            if(NOT OpenCL_FOUND)
                message(FATAL_ERROR "OpenCL must be installed for polly feature.")
            endif()
        elseif ("${_feature}" STREQUAL "compiler-rt")
            llvm_download(
                NAME compiler-rt
                EXTRACT_TO projects
                SHA512 69850c1ad92c66977fa217cbfb42a6a3f502fbe3d1a08daa7fc4cfeb617a7736d231f8ad8d93b10b1ae29bd753315d2a2d70f9ff1f4d18a9a7cc81758d91f963
            )
        elseif ("${_feature}" STREQUAL "libunwind")
            message(WARNING "The LLVM's libunwind does not work with Visual Studio sadly :(")
        #    llvm_download(
        #        NAME libunwind
        #        SHA512 78568c28720abdd1f8471c462421df9965e05e1db048689d16ac85378716c4080ec1723af78e9f61d133b0ff82ac8c1f0dde7fd42d194485f62c1a17c02db37f
        #    )
        #    list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_CROSS_UNWINDING=ON")
        #    list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_ARM_WMMX=ON")
        #    if ("compiler-rt" IN_LIST FEATURES)
        #        list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_USE_COMPILER_RT=ON")
        #    endif()
        #    list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_STATIC=ON")
        #    list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_SHARED=OFF")
        elseif ("${_feature}" STREQUAL "libomp")
            llvm_download(
                NAME openmp
                EXTRACT_TO projects
                SHA512 abb956583e5d11d0c6f6d97183c081d658616a74933be884a591eaa3d8c4bb04f08f02016d2c86d7384c7ff1aa44fb949b0d967fc0ff50e3132aaba412e9add8
            )
            vcpkg_find_acquire_program(PERL)
            get_filename_component(PERL_PATH ${PERL} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH};${PERL_PATH}")
            list(APPEND _COMPONENT_FLAGS "-DLIBOMP_OMPT_OPTIONAL=ON")
        elseif ("${_feature}" MATCHES "^libomp-")
            string(REPLACE "libomp-" "" _featureValue "${_feature}")

            if ("${_featureValue}" STREQUAL "debugger")
                list(APPEND _COMPONENT_FLAGS "-DLIBOMP_USE_DEBUGGER=ON")
            elseif ("${_featureValue}" STREQUAL "stats")
                list(APPEND _COMPONENT_FLAGS "-DLIBOMP_STATS=ON")
            endif()
        elseif ("${_feature}" STREQUAL "doxygen")
            vcpkg_find_acquire_program(DOXYGEN)
            get_filename_component(DOXYGEN_PATH ${DOXYGEN} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH};${DOXYGEN_PATH}")

            list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_DOCS=ON")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_ENABLE_DOXYGEN=ON")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_DOXYGEN_SVG=ON")
        #elseif ("${_feature}" STREQUAL "libcxx")
        # TODO must be compiled with CLANG when using ninja
        #    llvm_download(
        #        NAME libcxx
        #        EXTRACT_TO projects
        #        SHA512 c04f628b0924d76f035f615b59d19ce42dfc19c9a8eea4fe2b22a95cfe5a037ebdb30943fd741443939df5b4cf692bc1e51c840fefefbd134e3afbe2a75fe875
        #    )
        #    llvm_download(
        #        NAME libcxxabi
        #        EXTRACT_TO projects
        #        SHA512 bbb4c7b412e295cb735f637df48a83093eef45ed5444f7766790b4b047f75fd5fd634d8f3a8ac33a5c1407bd16fd450ba113f60a9bcc1d0a911fe0c54e9c81f2
        #    )
        endif()
    endif()
endforeach()

# Appyl patches
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/install-cmake-modules-to-share.patch
        ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-modules-llvm-options.patch
        ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-platform-msvc.patch
        ${_COMPONENT_PATCHES}
)

# Configure LLVM
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${_COMPONENT_FLAGS}
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_TOOLS_INSTALL_DIR=tools/llvm
)

# Invoke install
vcpkg_install_cmake()

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*)
file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/llvm)
file(COPY ${DEBUG_EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/llvm)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/clang TARGET_PATH share/clang)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/llvm)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/llvm)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/tools
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/tools/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/include/llvm/BinaryFormat/WasmRelocs
)

# Remove one empty include subdirectory if it is indeed empty
file(GLOB MCANALYSISFILES ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis/*)
if(NOT MCANALYSISFILES)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm RENAME copyright)
