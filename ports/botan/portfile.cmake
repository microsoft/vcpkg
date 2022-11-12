vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randombit/botan
    REF "${VERSION}"
    SHA512 b467f8613832873b3337794d52bb46ddc77ffa78ee3498481b67aec66d35acd347d34056c7bdf68b303b836f0da18ce11ffa751b4cfbdce606780c292b417827
    HEAD_REF master
    PATCHES
        fix-generate-build-path.patch
        embed-debug-info.patch
        arm64-windows.patch
        pkgconfig.patch
        verbose-install.patch
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

vcpkg_list(SET configure_arguments
    "--distribution-info=vcpkg ${TARGET_TRIPLET}"
    --with-pkg-config
    --link-method=copy
    --with-debug-info
    --includedir=include
    --bindir=bin
    --libdir=lib
    --without-documentation
    "--with-external-includedir=${CURRENT_INSTALLED_DIR}/include"
)

if("amalgamation" IN_LIST FEATURES)
    list(APPEND configure_arguments --amalgamation)
endif()
if("zlib" IN_LIST FEATURES)
    list(APPEND configure_arguments --with-zlib)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    vcpkg_list(APPEND configure_arguments --cpu=x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_list(APPEND configure_arguments --cpu=x86_64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    vcpkg_list(APPEND configure_arguments --cpu=arm32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    vcpkg_list(APPEND configure_arguments --cpu=arm64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND configure_arguments --os=windows)

    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        vcpkg_list(APPEND configure_arguments --cc=msvc)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_list(APPEND configure_arguments --enable-shared-library --disable-static-library)
    else()
        vcpkg_list(APPEND configure_arguments --disable-shared-library --enable-static-library)
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(BOTAN_MSVC_RUNTIME MD)
    else()
        set(BOTAN_MSVC_RUNTIME MT)
    endif()

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME "Makefile"
        PREFER_JOM
        PRERUN_SHELL_RELEASE
            "${PYTHON3}" "${SOURCE_PATH}/configure.py"
            ${configure_arguments}
            "--prefix=${CURRENT_PACKAGES_DIR}"
            "--msvc-runtime=${BOTAN_MSVC_RUNTIME}"
            "--with-external-libdir=${CURRENT_INSTALLED_DIR}/lib"
        PRERUN_SHELL_DEBUG
            "${PYTHON3}" "${SOURCE_PATH}/configure.py"
            ${configure_arguments}
            "--prefix=${CURRENT_PACKAGES_DIR}/debug"
            "--msvc-runtime=${BOTAN_MSVC_RUNTIME}d"
            "--with-external-libdir=${CURRENT_INSTALLED_DIR}/debug/lib"
            --debug-mode
    )
    vcpkg_copy_tools(TOOL_NAMES botan-cli AUTO_CLEAN)
    vcpkg_copy_pdbs()
else()
    if(VCPKG_TARGET_IS_MINGW)
        vcpkg_list(APPEND configure_arguments --os=mingw)
    endif()

    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        vcpkg_list(APPEND configure_arguments --cc=gcc)
    elseif(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        vcpkg_list(APPEND configure_arguments --cc=clang)
    endif()
    # botan's install.py doesn't handle DESTDIR on windows host,
    # so we must avoid the standard '--prefix' and 'DESTDIR' install.
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_VERBOSE_FLAGS
        NO_ADDITIONAL_PATHS
        OPTIONS
            "${PYTHON3}" "${SOURCE_PATH}/configure.py"
            ${configure_arguments}
        OPTIONS_RELEASE
            "--prefix=${CURRENT_PACKAGES_DIR}"
            "--with-external-libdir=${CURRENT_INSTALLED_DIR}/lib"
        OPTIONS_DEBUG
            --debug-mode
            "--prefix=${CURRENT_PACKAGES_DIR}/debug"
            "--with-external-libdir=${CURRENT_INSTALLED_DIR}/debug/lib"
    )
    vcpkg_build_make(BUILD_TARGET install)
    vcpkg_copy_tools(TOOL_NAMES botan AUTO_CLEAN)
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/include/botan-2/botan" "${CURRENT_PACKAGES_DIR}/include/botan")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/botan-2"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_PREFIX R\"(${CURRENT_PACKAGES_DIR})\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_LIB_DIR R\"(${CURRENT_PACKAGES_DIR}\\lib)\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_LIB_DIR R\"(${CURRENT_PACKAGES_DIR}/lib)\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "--prefix=${CURRENT_PACKAGES_DIR}" "")

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
