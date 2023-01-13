vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL https://chromium.googlesource.com/libyuv/libyuv
        REF 010dea8ba4158896e5608a52dd4372ca7f57cdca #2023-01-10
        PATCHES
        fix-cmakelists.patch
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Most of libyuv accelerated features need to be compiled by clang/gcc, so force use clang-cl, otherwise the performance is too poor.
    # Manually build the port with clang-cl when targeting windows and using MSVC as compiler

    message(STATUS "Set compiler to clang-cl when targeting windows and using MSVC")

    # https://github.com/microsoft/vcpkg/pull/10398
    set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)

    vcpkg_find_acquire_program(CLANG)
    if (CLANG MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Clang is required.")
    endif ()
    get_filename_component(CLANG "${CLANG}" DIRECTORY)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(CLANG_TRIPLE "arm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CLANG_TRIPLE "aarch64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CLANG_TRIPLE "i686")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CLANG_TRIPLE "x86_64")
    else()
        message(FATAL_ERROR "Unsupported target architecture")
    endif()

    set(CLANG_TRIPLE "${CLANG_TRIPLE}-pc-windows-msvc")

    message(STATUS "Using clang triple ${CLANG_TRIPLE}")
    string(APPEND VCPKG_DETECTED_CMAKE_CXX_FLAGS --target=${CLANG_TRIPLE})
    string(APPEND VCPKG_DETECTED_CMAKE_C_FLAGS --target=${CLANG_TRIPLE})

    vcpkg_cmake_configure(
            SOURCE_PATH ${SOURCE_PATH}
            OPTIONS
            -DCMAKE_CXX_COMPILER=${CLANG}/clang-cl.exe
            -DCMAKE_C_COMPILER=${CLANG}/clang-cl.exe
            -DCMAKE_CXX_FLAGS=${VCPKG_DETECTED_CMAKE_CXX_FLAGS}
            -DCMAKE_C_FLAGS=${VCPKG_DETECTED_CMAKE_C_FLAGS}
            OPTIONS_DEBUG
            -DCMAKE_DEBUG_POSTFIX=d
    )
else ()
    vcpkg_cmake_configure(
            SOURCE_PATH ${SOURCE_PATH}
            OPTIONS_DEBUG
            -DCMAKE_DEBUG_POSTFIX=d
    )
endif ()

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libyuv)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${CMAKE_CURRENT_LIST_DIR}/libyuv-config.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT} COPYONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
