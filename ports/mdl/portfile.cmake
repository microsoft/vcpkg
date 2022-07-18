vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Clang 7 build tool

set(LLVM_VERSION 7.0.0)
set(LLVM_BASE_URL "https://releases.llvm.org/${LLVM_VERSION}")

if(VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LLVM_DIRECTORY "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}/win64")
        set(LLVM_FILENAME  "LLVM-${LLVM_VERSION}-win64.exe")
        set(LLVM_HASH      c2b1342469275279f833fdc1e17ba5a9f99021306d6ab3d7209822a01d690767739eebf92fd9f23a44de5c5d00260fed50d5262b23a8eccac55b8ae901e2815c)
        set(LLVM_CLANG7    "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}/win64/bin/clang${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    else()
        message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}, architecture: ${VCPKG_TARGET_ARCHITECTURE}).")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LLVM_DIRECTORY "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}")
        set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04.tar.xz")
        set(LLVM_HASH      fb3dc588137426dc28a20ef5e34e9341b18114f03bf7d83fafbb301efbfd801bba08615b804817c80252e366de9d2f8efbef034e53a1b885b34c86c2fbbf9c28)
        set(LLVM_CLANG7    "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04/bin/clang${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    else()
        message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}, architecture: ${VCPKG_TARGET_ARCHITECTURE}).")
    endif()
elseif(VCPKG_TARGET_IS_FREEBSD)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LLVM_DIRECTORY "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}")
        set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-amd64-unknown-freebsd11.tar.xz")
        set(LLVM_HASH      d501484c38cfced196128866a19f7fef1e0b5d609ea050d085b7deab04ac8cc2bbf74b3cfe6cd90d8ea17a1d9cfca028a6c933f0736153ba48785ddc8646574f)
        set(LLVM_CLANG7    "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-amd64-unknown-freebsd11/bin/clang${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    else()
        message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}, architecture: ${VCPKG_TARGET_ARCHITECTURE}).")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LLVM_DIRECTORY "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}")
        set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz")
        set(LLVM_HASH      c5ca6a7756e0cecdf78d4d0c522fe7e803d4b1b2049cb502a034fe8f5ca30fcbf0e738ebfbc89c87de8adcd90ea64f637eb82e9130bb846b43b91f67dfa4b916)
        set(LLVM_CLANG7    "${DOWNLOADS}/tools/llvm-${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin/bin/clang${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    else()
        message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}, architecture: ${VCPKG_TARGET_ARCHITECTURE}).")
    endif()
else()
    message(FATAL_ERROR "Pre-built binaries for Clang 7 not available, aborting install (platform: ${VCPKG_CMAKE_SYSTEM_NAME}, architecture: ${VCPKG_TARGET_ARCHITECTURE}).")
endif()

include(CMakePrintHelpers)
cmake_print_variables(LLVM_BASE_URL LLVM_FILENAME LLVM_CLANG7)

if(NOT EXISTS ${LLVM_CLANG7})
    vcpkg_download_distfile(LLVM_ARCHIVE_PATH
      URLS     "${LLVM_BASE_URL}/${LLVM_FILENAME}"
      SHA512   ${LLVM_HASH}
      FILENAME "${LLVM_FILENAME}"
    )

    file(MAKE_DIRECTORY "${LLVM_DIRECTORY}")

    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_find_acquire_program(7Z)
        vcpkg_execute_in_download_mode(
            COMMAND ${7Z} x
                "${LLVM_ARCHIVE_PATH}"
                "-o${LLVM_DIRECTORY}"
                -y -bso0 -bsp0
            WORKING_DIRECTORY "${LLVM_DIRECTORY}"
        )
    else()
        vcpkg_execute_in_download_mode(
            COMMAND "${CMAKE_COMMAND}" -E tar xzf "${LLVM_ARCHIVE_PATH}"
            WORKING_DIRECTORY "${LLVM_DIRECTORY}"
        )
    endif()

    if(NOT EXISTS "${LLVM_CLANG7}")
        message(FATAL_ERROR "Missing required build tool clang 7, please check your setup.")
    endif()
endif()

# MDL-SDK

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
