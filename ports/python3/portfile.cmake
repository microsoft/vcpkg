if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(NOT VCPKG_HOST_IS_WINDOWS)
    message(WARNING "${PORT} currently requires the following programs from the system package manager:
    autoconf automake autoconf-archive
On Debian and Ubuntu derivatives:
    sudo apt-get install autoconf automake autoconf-archive
On recent Red Hat and Fedora derivatives:
    sudo dnf install autoconf automake autoconf-archive
On Arch Linux and derivatives:
    sudo pacman -S autoconf automake autoconf-archive
On Alpine:
    apk add autoconf automake autoconf-archive
On macOS:
    brew install autoconf automake autoconf-archive\n")
endif()

string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" PYTHON_VERSION "${VERSION}")
set(PYTHON_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_2}")
set(PYTHON_VERSION_PATCH "${CMAKE_MATCH_3}")

set(PATCHES
    0001-only-build-required-projects.patch
    0003-use-vcpkg-zlib.patch
    0004-devendor-external-dependencies.patch
    0005-dont-copy-vcruntime.patch
    0008-python.pc.patch
    0010-dont-skip-rpath.patch
    0012-force-disable-modules.patch
    0014-fix-get-python-inc-output.patch
    0015-dont-use-WINDOWS-def.patch
    0016-undup-ffi-symbols.patch # Required for lld-link.
    0018-fix-sysconfig-include.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND PATCHES 0002-static-library.patch)
endif()

# Fix build failures with GCC for built-in modules (https://github.com/microsoft/vcpkg/issues/26573)
if(VCPKG_TARGET_IS_LINUX)
    list(APPEND PATCHES 0011-gcc-ldflags-fix.patch)
endif()

# Python 3.9 removed support for Windows 7. This patch re-adds support for Windows 7 and is therefore
# required to build this port on Windows 7 itself due to Python using itself in its own build system.
if("deprecated-win7-support" IN_LIST FEATURES)
    list(APPEND PATCHES 0006-restore-support-for-windows-7.patch)
    message(WARNING "Windows 7 support is deprecated and may be removed at any time.")
elseif(VCPKG_TARGET_IS_WINDOWS AND CMAKE_SYSTEM_VERSION EQUAL 6.1)
    message(FATAL_ERROR "python3 requires the feature deprecated-win7-support when building on Windows 7.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PYTHON_ALLOW_EXTENSIONS)
    # The Windows 11 SDK has a problem that causes it to error on the resource files, so we patch that.
    vcpkg_get_windows_sdk(WINSDK_VERSION)
    if("${WINSDK_VERSION}" VERSION_GREATER_EQUAL "10.0.22000")
        list(APPEND PATCHES "0007-workaround-windows-11-sdk-rc-compiler-error.patch")
    endif()
    if(VCPKG_CROSSCOMPILING)
        list(APPEND PATCHES "0016-fix-win-cross.patch")
    else()
        list(APPEND PATCHES "0017-fix-win.patch")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO python/cpython
    REF v${PYTHON_VERSION}
    SHA512 c2ebe72ce53dd2d59750a7b0bdaf15ebb7ecb6f67d2913a457bf5d32bd0f640815f9496f2fa3ebeac0722264d000735d90d3ffaeac2de1f066b7aee994bf9b24
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_replace_string("${SOURCE_PATH}/Makefile.pre.in" "$(INSTALL) -d -m $(DIRMODE)" "$(MKDIR_P)")

function(make_python_pkgconfig)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "FILE;INSTALL_ROOT;EXEC_PREFIX;INCLUDEDIR;ABIFLAGS" "")

    set(prefix "${CURRENT_PACKAGES_DIR}")
    set(libdir [[${prefix}/lib]])
    set(exec_prefix ${arg_EXEC_PREFIX})
    set(includedir ${arg_INCLUDEDIR})
    set(VERSION "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
    set(ABIFLAGS ${arg_ABIFLAGS})

    string(REPLACE "python" "python-${VERSION}" out_file ${arg_FILE})
    set(out_full_path "${arg_INSTALL_ROOT}/lib/pkgconfig/${out_file}")
    configure_file("${SOURCE_PATH}/Misc/${arg_FILE}.in" ${out_full_path} @ONLY)

    file(READ ${out_full_path} pkgconfig_file)
    string(REPLACE "-lpython${VERSION}" "-lpython${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}" pkgconfig_file "${pkgconfig_file}")
    file(WRITE ${out_full_path} "${pkgconfig_file}")
endfunction()

if(VCPKG_TARGET_IS_WINDOWS)
    # Due to the way Python handles C extension modules on Windows, a static python core cannot
    # load extension modules.
    if(PYTHON_ALLOW_EXTENSIONS)
        find_library(BZ2_RELEASE NAMES bz2 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(BZ2_DEBUG NAMES bz2d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(CRYPTO_RELEASE NAMES libcrypto PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(CRYPTO_DEBUG NAMES libcrypto PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(EXPAT_RELEASE NAMES libexpat libexpatMD libexpatMT PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(EXPAT_DEBUG NAMES libexpatd libexpatdMD libexpatdMT PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(FFI_RELEASE NAMES ffi PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(FFI_DEBUG NAMES ffi PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(LZMA_RELEASE NAMES lzma PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(LZMA_DEBUG NAMES lzma PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(SQLITE_RELEASE NAMES sqlite3 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(SQLITE_DEBUG NAMES sqlite3 PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(SSL_RELEASE NAMES libssl PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(SSL_DEBUG NAMES libssl PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
        list(APPEND add_libs_rel "${BZ2_RELEASE};${EXPAT_RELEASE};${FFI_RELEASE};${LZMA_RELEASE};${SQLITE_RELEASE}")
        list(APPEND add_libs_dbg "${BZ2_DEBUG};${EXPAT_DEBUG};${FFI_DEBUG};${LZMA_DEBUG};${SQLITE_DEBUG}")
    else()
        message(STATUS "WARNING: Static builds of Python will not have C extension modules available.")
    endif()
    find_library(ZLIB_RELEASE NAMES zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
    find_library(ZLIB_DEBUG NAMES zlib zlibd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    list(APPEND add_libs_rel "${ZLIB_RELEASE}")
    list(APPEND add_libs_dbg "${ZLIB_DEBUG}")

    configure_file("${SOURCE_PATH}/PC/pyconfig.h" "${SOURCE_PATH}/PC/pyconfig.h")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/python_vcpkg.props.in" "${SOURCE_PATH}/PCbuild/python_vcpkg.props")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/openssl.props.in" "${SOURCE_PATH}/PCbuild/openssl.props")
    file(WRITE "${SOURCE_PATH}/PCbuild/libffi.props"
        "<?xml version='1.0' encoding='utf-8'?>"
        "<Project xmlns='http://schemas.microsoft.com/developer/msbuild/2003' />"
    )

    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_SET_CHARSET_FLAG=OFF")
    if(PYTHON_ALLOW_EXTENSIONS)
        set(OPTIONS
            "/p:IncludeExtensions=true"
            "/p:IncludeExternals=true"
            "/p:IncludeCTypes=true"
            "/p:IncludeSSL=true"
            "/p:IncludeTkinter=false"
            "/p:IncludeTests=false"
            "/p:ForceImportBeforeCppTargets=${SOURCE_PATH}/PCbuild/python_vcpkg.props"
        )
    else()
        set(OPTIONS
            "/p:IncludeExtensions=false"
            "/p:IncludeExternals=false"
            "/p:IncludeTests=false"
            "/p:ForceImportBeforeCppTargets=${SOURCE_PATH}/PCbuild/python_vcpkg.props"
        )
    endif()
    if(VCPKG_TARGET_IS_UWP)
        list(APPEND OPTIONS "/p:IncludeUwp=true")
    else()
        list(APPEND OPTIONS "/p:IncludeUwp=false")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND OPTIONS "/p:_VcpkgPythonLinkage=DynamicLibrary")
    else()
        list(APPEND OPTIONS "/p:_VcpkgPythonLinkage=StaticLibrary")
    endif()

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    set(ENV{PythonForBuild} "${PYTHON3_DIR}/python.exe") # PythonForBuild is what's used on windows, despite the readme

    if(VCPKG_CROSSCOMPILING)
        vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "PCbuild/pcbuild.proj"
        ADD_BIN_TO_PATH
        OPTIONS ${OPTIONS}
        ADDITIONAL_LIBS_RELEASE ${add_libs_rel}
        ADDITIONAL_LIBS_DEBUG ${add_libs_dbg}
    )

    if(NOT VCPKG_CROSSCOMPILING)
        file(GLOB_RECURSE freeze_module "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/PCbuild/**/_freeze_module.exe")
        file(COPY "${freeze_module}" DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
    endif()

    # The extension modules must be placed in the DLLs directory, so we can't use vcpkg_copy_tools()
    if(PYTHON_ALLOW_EXTENSIONS)
        file(GLOB_RECURSE PYTHON_EXTENSIONS_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.pyd")
        file(COPY ${PYTHON_EXTENSIONS_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(COPY ${PYTHON_EXTENSIONS_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/DLLs")
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/DLLs")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/DLLs/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll")

        file(GLOB_RECURSE PYTHON_EXTENSIONS_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.pyd")
        file(COPY ${PYTHON_EXTENSIONS_DEBUG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    file(COPY "${SOURCE_PATH}/Include/" "${SOURCE_PATH}/PC/pyconfig.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
        FILES_MATCHING PATTERN *.h
    )
    file(COPY "${SOURCE_PATH}/Lib" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    # Remove any extension libraries and other unversioned binaries that could conflict with the python2 port.
    # You don't need to link against these anyway.
    file(GLOB PYTHON_LIBS
        "${CURRENT_PACKAGES_DIR}/lib/*.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib"
    )
    list(FILTER PYTHON_LIBS EXCLUDE REGEX [[python[0-9]*(_d)?\.lib$]])
    file(GLOB PYTHON_INSTALLERS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wininst-*.exe")
    file(REMOVE ${PYTHON_LIBS} ${PYTHON_INSTALLERS})

    # pkg-config files
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        make_python_pkgconfig(FILE python.pc INSTALL_ROOT ${CURRENT_PACKAGES_DIR}
            EXEC_PREFIX "\${prefix}/tools/${PORT}" INCLUDEDIR [[${prefix}/include]] ABIFLAGS "")
        make_python_pkgconfig(FILE python-embed.pc INSTALL_ROOT ${CURRENT_PACKAGES_DIR}
            EXEC_PREFIX "\${prefix}/tools/${PORT}" INCLUDEDIR [[${prefix}/include]] ABIFLAGS "")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        make_python_pkgconfig(FILE python.pc INSTALL_ROOT "${CURRENT_PACKAGES_DIR}/debug"
            EXEC_PREFIX "\${prefix}/../tools/${PORT}" INCLUDEDIR [[${prefix}/../include]] ABIFLAGS "_d")
        make_python_pkgconfig(FILE python-embed.pc INSTALL_ROOT "${CURRENT_PACKAGES_DIR}/debug"
            EXEC_PREFIX "\${prefix}/../tools/${PORT}" INCLUDEDIR [[${prefix}/../include]] ABIFLAGS "_d")
    endif()

    vcpkg_fixup_pkgconfig()

    # Remove static library belonging to executable
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if (EXISTS "${CURRENT_PACKAGES_DIR}/lib/python.lib")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/python.lib"
                "${CURRENT_PACKAGES_DIR}/lib/manual-link/python.lib")
        endif()
        if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/python_d.lib")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/python_d.lib"
                "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/python_d.lib")
        endif()
    endif()
else()
    # The Python Stable ABI, `libpython3.so` is not produced by the upstream build system with --with-pydebug option
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND NOT VCPKG_BUILD_TYPE)
        set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
    endif()

    set(OPTIONS
        "--with-openssl=${CURRENT_INSTALLED_DIR}"
        "--without-ensurepip"
        "--with-suffix="
        "--with-system-expat"
        "--without-readline"
        "--disable-test-modules"
    )
    if(VCPKG_TARGET_IS_OSX)
        list(APPEND OPTIONS "LIBS=-liconv -lintl")
    endif()

    # The version of the build Python must match the version of the cross compiled host Python.
    # https://docs.python.org/3/using/configure.html#cross-compiling-options
    if(VCPKG_CROSSCOMPILING)
        set(_python_for_build "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
        list(APPEND OPTIONS "--with-build-python=${_python_for_build}")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${OPTIONS}
        OPTIONS_DEBUG
            "--with-pydebug"
            "vcpkg_rpath=${CURRENT_INSTALLED_DIR}/debug/lib"
        OPTIONS_RELEASE
            "vcpkg_rpath=${CURRENT_INSTALLED_DIR}/lib"
    )
    vcpkg_install_make(ADD_BIN_TO_PATH INSTALL_TARGET altinstall)

    file(COPY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    # Makefiles, c files, __pycache__, and other junk.
    file(GLOB PYTHON_LIB_DIRS LIST_DIRECTORIES true
        "${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/*"
        "${CURRENT_PACKAGES_DIR}/debug/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/*")
    list(FILTER PYTHON_LIB_DIRS INCLUDE REGEX [[config-[0-9].*.*]])
    file(REMOVE_RECURSE ${PYTHON_LIB_DIRS})

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}d")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

    vcpkg_fixup_pkgconfig()

    # Perform some post-build checks on modules
    file(GLOB python_libs_dynload_debug LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/debug/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/lib-dynload/*.so*")
    file(GLOB python_libs_dynload_release LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/lib-dynload/*.so*")
    set(python_libs_dynload_failed_debug ${python_libs_dynload_debug})
    set(python_libs_dynload_failed_release ${python_libs_dynload_release})
    list(FILTER python_libs_dynload_failed_debug INCLUDE REGEX ".*_failed\.so.*")
    list(FILTER python_libs_dynload_failed_release INCLUDE REGEX ".*_failed\.so.*")
    if(python_libs_dynload_failed_debug OR python_libs_dynload_failed_release)
        list(JOIN python_libs_dynload_failed_debug "\n" python_libs_dynload_failed_debug_str)
        list(JOIN python_libs_dynload_failed_release "\n" python_libs_dynload_failed_release_str)
        message(FATAL_ERROR "There should be no modules with \"_failed\" suffix:\n${python_libs_dynload_failed_debug_str}\n${python_libs_dynload_failed_release_str}")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
        list(LENGTH python_libs_dynload_release python_libs_dynload_release_length)
        list(LENGTH python_libs_dynload_debug python_libs_dynload_debug_length)
        if(NOT python_libs_dynload_release_length STREQUAL python_libs_dynload_debug_length)
            message(FATAL_ERROR "Mismatched number of modules: ${python_libs_dynload_debug_length} in debug, ${python_libs_dynload_release_length} in release")
        endif()
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
if(VCPKG_TARGET_IS_WINDOWS)
    if(PYTHON_ALLOW_EXTENSIONS)
        file(READ "${CMAKE_CURRENT_LIST_DIR}/usage.win" usage_extra)
    else()
        set(usage_extra "")
    endif()
else()
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage.unix" usage_extra)
endif()
string(REPLACE "@PYTHON_VERSION_MINOR@" "${PYTHON_VERSION_MINOR}" usage_extra "${usage_extra}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage}\n${usage_extra}")

function(_generate_finder)
    cmake_parse_arguments(PythonFinder "NO_OVERRIDE" "DIRECTORY;PREFIX" "" ${ARGN})
    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
        "${CURRENT_PACKAGES_DIR}/share/${PythonFinder_DIRECTORY}/vcpkg-cmake-wrapper.cmake"
        @ONLY
    )
endfunction()

message(STATUS "Installing cmake wrappers")
_generate_finder(DIRECTORY "python" PREFIX "Python")
_generate_finder(DIRECTORY "python3" PREFIX "Python3")
_generate_finder(DIRECTORY "pythoninterp" PREFIX "PYTHON" NO_OVERRIDE)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    function(replace_dirs_in_config_file python_config_file)
        vcpkg_replace_string("${python_config_file}" "${CURRENT_INSTALLED_DIR}" "' + _base + '")
        vcpkg_replace_string("${python_config_file}" "${CURRENT_HOST_INSTALLED_DIR}" "' + _base + '/../${HOST_TRIPLET}" IGNORE_UNCHANGED)
        vcpkg_replace_string("${python_config_file}" "${CURRENT_PACKAGES_DIR}" "' + _base + '")
        vcpkg_replace_string("${python_config_file}" "${CURRENT_BUILDTREES_DIR}" "not/existing")
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB python_config_files "${CURRENT_PACKAGES_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/_sysconfigdata*")
        list(POP_FRONT python_config_files python_config_file)
        vcpkg_replace_string("${python_config_file}" "# system configuration generated and used by the sysconfig module" "# system configuration generated and used by the sysconfig module\nimport os\n_base = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))\n")
        replace_dirs_in_config_file("${python_config_file}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB python_config_files "${CURRENT_PACKAGES_DIR}/debug/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/_sysconfigdata*")
        list(POP_FRONT python_config_files python_config_file)
        vcpkg_replace_string("${python_config_file}" "# system configuration generated and used by the sysconfig module" "# system configuration generated and used by the sysconfig module\nimport os\n_base = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))\n")
        replace_dirs_in_config_file("${python_config_file}")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/python3/Lib/distutils/command/build_ext.py" "'libs'" "'../../lib'")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/python3.${PYTHON_VERSION_MINOR}/distutils/command/build_ext.py" "'libs'" "'../../lib'")
  file(COPY_FILE "${CURRENT_PACKAGES_DIR}/tools/python3/python3.${PYTHON_VERSION_MINOR}" "${CURRENT_PACKAGES_DIR}/tools/python3/python3")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/python3/vcpkg-port-config.cmake" @ONLY)

# For testing
block()
  set(CURRENT_HOST_INSTALLED_DIR "${CURRENT_PACKAGES_DIR}")
  vcpkg_get_vcpkg_installed_python(VCPKG_PYTHON3)
endblocK()