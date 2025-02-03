vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randombit/botan
    REF "${VERSION}"
    SHA512 dcd9ac8e748422d55854c38e565704e4a239418b6855836bdea85bd4dc3ab45e218d320471b98b6a451fc63d8518895f3813a50c94dee90227c09d12d96ca1dc
    HEAD_REF master
    PATCHES
        embed-debug-info.patch
        pkgconfig.patch
        verbose-install.patch
        configure-zlib.patch
        fix_android.patch
        libcxx-winpthread-fixes.patch
        fix-cmake-usage.patch
        0009-fix-regression-f2bf049-85491b3.patch # extract from PR 4255
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

set(pkgconfig_syntax "")
if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(pkgconfig_syntax "--msvc-syntax")
endif()

vcpkg_list(SET configure_arguments
    "--distribution-info=vcpkg ${TARGET_TRIPLET}"
    --disable-cc-tests
    --with-pkg-config
    --link-method=copy
    --with-debug-info
    --includedir=include
    --bindir=bin
    --libdir=lib
    --without-documentation
    "--with-external-includedir=${CURRENT_INSTALLED_DIR}/include"
)
vcpkg_list(SET pkgconfig_requires)

if("amalgamation" IN_LIST FEATURES)
    vcpkg_list(APPEND configure_arguments --amalgamation)
endif()

set(ZLIB_LIBS_RELEASE "")
set(ZLIB_LIBS_DEBUG "")
if("zlib" IN_LIST FEATURES)
    vcpkg_list(APPEND configure_arguments --with-zlib)
    vcpkg_list(APPEND pkgconfig_requires zlib)
    x_vcpkg_pkgconfig_get_modules(LIBS PREFIX "ZLIB" MODULES "zlib" ${pkgconfig_syntax})
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_list(APPEND configure_arguments --cpu=wasm)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
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

# Allow disabling use of WinSock2 by setting BOTAN_USE_WINSOCK2=OFF in triplet
# for targeting older Windows versions with missing APIs.
if(VCPKG_TARGET_IS_WINDOWS AND DEFINED BOTAN_USE_WINSOCK2 AND NOT BOTAN_USE_WINSOCK2)
    vcpkg_list(APPEND configure_arguments --without-os-features=winsock2)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND configure_arguments --os=windows)

    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        vcpkg_list(APPEND configure_arguments --cc=msvc)
    endif()

    # When compiling with Clang, -mrdrand is required to enable the RDRAND intrinsics. Botan will
    # check for RDRAND at runtime before trying to use it, so we should be safe to specify this
    # without triggering illegal instruction faults on older CPUs.
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER MATCHES "clang-cl(\.exe)?$")
        vcpkg_list(APPEND configure_arguments "--extra-cxxflags=${VCPKG_DETECTED_CMAKE_CXX_FLAGS} -mrdrnd")
    else()
        # ...otherwise just forward the detected CXXFLAGS.
        vcpkg_list(APPEND configure_arguments "--extra-cxxflags=${VCPKG_DETECTED_CMAKE_CXX_FLAGS}")
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
        OPTIONS
            "CXX=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\""
            "LINKER=\"${VCPKG_DETECTED_CMAKE_LINKER}\""
            "AR=\"${VCPKG_DETECTED_CMAKE_AR}\""
            "EXE_LINK_CMD=\"${VCPKG_DETECTED_CMAKE_LINKER}\" ${VCPKG_LINKER_FLAGS}"
        OPTIONS_RELEASE
            "ZLIB_LIBS=${ZLIB_LIBS_RELEASE}"
        OPTIONS_DEBUG
            "ZLIB_LIBS=${ZLIB_LIBS_DEBUG}"
    )
    vcpkg_copy_tools(TOOL_NAMES botan-cli AUTO_CLEAN)
    vcpkg_copy_pdbs()
else()
    if(VCPKG_TARGET_IS_ANDROID)
        vcpkg_list(APPEND configure_arguments --os=android)
    elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
        vcpkg_list(APPEND configure_arguments --os=emscripten)
    elseif(VCPKG_TARGET_IS_MINGW)
        vcpkg_list(APPEND configure_arguments --os=mingw)
    endif()

    if(VCPKG_TARGET_IS_EMSCRIPTEN)
        vcpkg_list(APPEND configure_arguments --cc=emcc)
    elseif(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
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
    vcpkg_build_make(
        BUILD_TARGET install
        OPTIONS
            "ZLIB_LIBS_RELEASE=${ZLIB_LIBS_RELEASE}"
            "ZLIB_LIBS_DEBUG=${ZLIB_LIBS_DEBUG}"
    )
    if(NOT VCPKG_TARGET_IS_EMSCRIPTEN)
        vcpkg_copy_tools(TOOL_NAMES botan AUTO_CLEAN)
    endif()
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Botan-${VERSION}")

file(RENAME "${CURRENT_PACKAGES_DIR}/include/botan-3/botan" "${CURRENT_PACKAGES_DIR}/include/botan")

if(pkgconfig_requires)
    list(JOIN pkgconfig_requires ", " pkgconfig_requires)
    file(APPEND "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/botan-3.pc" "Requires.private: ${pkgconfig_requires}")
    if(NOT VCPKG_BUILD_TYPE)
        file(APPEND "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/botan-3.pc" "Requires.private: ${pkgconfig_requires}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/botan-3"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_PREFIX R\"(${CURRENT_PACKAGES_DIR})\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_LIB_DIR R\"(${CURRENT_PACKAGES_DIR}\\lib)\"" "" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "#define BOTAN_INSTALL_LIB_DIR R\"(${CURRENT_PACKAGES_DIR}/lib)\"" "" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/botan/build.h" "--prefix=${CURRENT_PACKAGES_DIR}" "")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
