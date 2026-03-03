# - The static lib is named "ssl", conflicting with the "ssl" lib from openssl.
# - The tools use the shared libs.
# - The pkgconfig file refers to "ssl3"
# - Linux distros don't install the static lib.
# (Renaming the static lib to "ssl3" might be an alternative solution.)
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REPLACE "." "_" V_URL ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.mozilla.org/pub/security/nss/releases/NSS_${V_URL}_RTM/src/nss-${VERSION}.tar.gz"
    FILENAME "nss-${VERSION}.tar.gz"
    SHA512 5ffb1182e7d65f8895c09656d20bc7146d1616cd4f09046469b2f79f60b57083094c78da39a3f3faa5087742a19f706ce9e7928a662f9f0d3c410514cba2028f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES
        "02-gen-debug-info-for-release.patch"
        "03-use-debug-crt-for-debug.patch" # See https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.vcprojectengine.runtimelibraryoption
        include-dirs.diff
        macos-cross-compile.patch
)
file(GLOB devendor "${SOURCE_PATH}/nss/lib/sqlite/*.?" "${SOURCE_PATH}/nss/lib/zlib/*.?")
file(REMOVE ${devendor})
file(COPY "${CURRENT_PORT_DIR}/configure" DESTINATION "${SOURCE_PATH}")

function(download_distfile var url sha512)
    string(REGEX REPLACE ".*/" "" filename "${url}")
    vcpkg_download_distfile(archive
        URLS "${url}"
        FILENAME "${filename}"
        SHA512 "${sha512}"
    )
    set("${var}" "${archive}" PARENT_SCOPE)
endfunction()

download_distfile(gyp_next
    "https://files.pythonhosted.org/packages/37/3e/d920a254ad927c942a541388c84dd1af0db1af6f6c2b96e99d9ec3f3a148/gyp_next-0.20.2-py3-none-any.whl"
    53feff516d0de8738910e04e4e5664af27947c0a2bca856c290f9082d18678b03e917403e2c842edb62b6dd5412c625f34edb52d6d9b295c07ef34b3c18981f8
)
download_distfile(packaging
    "https://files.pythonhosted.org/packages/20/12/38679034af332785aac8774540895e234f4d07f7545804097de4b666afd8/packaging-25.0-py3-none-any.whl"
    a726fb46cce24f781fc8b55a3e6dea0a884ebc3b2b400ea74aa02333699f4955a5dc1e2ec5927ac72f35a624401f3f3b442882ba1cc4cadaf9c88558b5b8bdae
)
download_distfile(setuptools
    "https://files.pythonhosted.org/packages/a3/dc/17031897dae0efacfea57dfd3a82fdd2a2aeb58e0ff71b77b87e44edc772/setuptools-80.9.0-py3-none-any.whl"
    2a0420f7faaa33d2132b82895a8282688030e939db0225ad8abb95a47bdb87b45318f10985fc3cee271a9121441c1526caa363d7f2e4a4b18b1a674068766e87
)
x_vcpkg_get_python_packages(
    OUT_PYTHON_VAR PYTHON3
    PYTHON_VERSION 3
    PACKAGES "${gyp_next}" "${packaging}" "${setuptools}"
)
cmake_path(GET PYTHON3 PARENT_PATH GYP_NEXT_ROOT)

# Prepend to PATH in controlled order
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_ROOT "${NINJA}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NINJA_ROOT}")

find_program(GYP_NEXT NAMES gyp PATHS "${GYP_NEXT_ROOT}" NO_DEFAULT_PATH REQUIRED)
message(STATUS "Using ${GYP_NEXT}")
vcpkg_add_to_path(PREPEND "${GYP_NEXT_ROOT}")

# setup build.sh options -- see help.txt in nss root
set(OPTIONS "")
if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND OPTIONS "-DOS=android")
elseif(VCPKG_TARGET_IS_FREEBSD)
    list(APPEND OPTIONS "-DOS=freebsd")
elseif(VCPKG_TARGET_IS_IOS)
    list(APPEND OPTIONS "-DOS=ios")
elseif(VCPKG_TARGET_IS_LINUX)
    list(APPEND OPTIONS "-DOS=linux")
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS "-DOS=mac")
elseif(VCPKG_TARGET_IS_OPENBSD)
    list(APPEND OPTIONS "-DOS=openbsd")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-DOS=win")
elseif(VCPKG_CROSSCOMPILING)
    message(WARNING "Cannot determine OS setting for ${TARGET_TRIPLET}")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND OPTIONS "--target=ia32")
else()
    list(APPEND OPTIONS "--target=${VCPKG_TARGET_ARCHITECTURE}")
endif()

function(cygpath_u out_var input) # equivalent to cygpath -u
    string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" input "${input}")
    set("${out_var}" "${input}" PARENT_SCOPE)
endfunction()

if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_MSVC)
        list(APPEND OPTIONS "--msvc")
        set(ENV{PYTHONUTF8} 1)

        # vswhere needed in PATH
        cmake_path(SET vswhere "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer/vswhere.exe")
        if(NOT EXISTS "${vswhere}")
            vcpkg_execute_in_download_mode(
                COMMAND "$ENV{VCPKG_COMMAND}" fetch vswhere --x-stderr-status
                OUTPUT_VARIABLE vswhere
                RESULT_VARIABLE error_code
                OUTPUT_STRIP_TRAILING_WHITESPACE
                WORKING_DIRECTORY "${DOWNLOADS}"
            )
            if(NOT error_code STREQUAL "0")
                message(FATAL_ERROR "Failed to fetch vswhere.")
            endif()
            string(REGEX REPLACE "^.*\n *" "" vswhere "${vswhere}")
        endif()
        message(STATUS "Using ${vswhere}")
        cmake_path(GET vswhere PARENT_PATH vswhere_dir)
        vcpkg_host_path_list(APPEND ENV{PATH} "${vswhere_dir}")

        # Set GYP_MSVS_OVERRIDE_PATH and GYP_MSVS_VERSION for actual cl.exe
        if("$ENV{GYP_MSVS_OVERRIDE_PATH}" STREQUAL "" OR "$ENV{GYP_MSVS_VERSION}" STREQUAL "")
            execute_process(
                COMMAND "${vswhere}"
                    -nologo
                    -property resolvedInstallationPath
                    -path "${VCPKG_DETECTED_CMAKE_C_COMPILER}"
                OUTPUT_VARIABLE msvs_installdir
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            message(STATUS "MSVS resolvedInstallationPath: ${msvs_installdir}")
            if(NOT EXISTS "${msvs_installdir}")
                message(FATAL_ERROR "Failed to determine MSVS dir for ${VCPKG_DETECTED_CMAKE_C_COMPILER}.")
            endif()
            cygpath_u(vspath "${msvs_installdir}")
            set(ENV{VSPATH} "${vspath}")
            set(ENV{GYP_MSVS_OVERRIDE_PATH} "${vspath}")

            execute_process(
                COMMAND "${vswhere}"
                    -nologo
                    -property catalog_productLineVersion
                    -path "${VCPKG_DETECTED_CMAKE_C_COMPILER}"
                OUTPUT_VARIABLE msvs_version
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            message(STATUS "MSVS catalog_productLineVersion: ${msvs_version}")
            if(NOT msvs_version MATCHES "^20..e?\$")
                message(FATAL_ERROR "Failed to determine MSVS version for ${VCPKG_DETECTED_CMAKE_C_COMPILER}.")
            endif()
            set(ENV{GYP_MSVS_VERSION} "${msvs_version}")
        endif()
    endif()
endif()

x_vcpkg_pkgconfig_get_modules(PREFIX PC_NSPR MODULES nspr CFLAGS LIBS)
x_vcpkg_pkgconfig_get_modules(PREFIX PC_SQLITE MODULES sqlite3 CFLAGS LIBS)
x_vcpkg_pkgconfig_get_modules(PREFIX PC_ZLIB MODULES zlib CFLAGS LIBS)
# Produce absolute include dirs and library dirs filepaths.
# Manually managing MSVC syntax because gyp converts foo.lib as if it were a relative path.
foreach(key IN ITEMS NSPR_CFLAGS_RELEASE SQLITE_CFLAGS_RELEASE ZLIB_CFLAGS_RELEASE)
    separate_arguments(cflags UNIX_COMMAND "${PC_${key}}")
    string(REPLACE "CFLAGS_RELEASE" "INCLUDE_DIRS" out_var "${key}")
    set(${out_var} "")
    foreach(item IN LISTS cflags)
        if(item MATCHES "^-I(.*)")
            cmake_path(SET dir NORMALIZE "${CMAKE_MATCH_1}")
            if(CMAKE_HOST_WIN32)
                cygpath_u(dir "${dir}")
            else()
            endif()
            list(APPEND ${out_var} "${dir}")
        endif()
    endforeach()
    list(JOIN ${key}_INCLUDE_DIRS ":" ${key}_INCLUDE_DIRS)
endforeach()
foreach(out_var IN ITEMS NSPR_LIBS_RELEASE NSPR_LIBS_DEBUG SQLITE_LIBS_RELEASE SQLITE_LIBS_DEBUG ZLIB_LIBS_RELEASE ZLIB_LIBS_DEBUG)
    separate_arguments(libs UNIX_COMMAND "${PC_${out_var}}")
    set(${out_var} "")
    foreach(item IN LISTS libs)
        if(item MATCHES "^-L(.*)")
            cmake_path(SET dir NORMALIZE "${CMAKE_MATCH_1}")
            if(CMAKE_HOST_WIN32)
                cygpath_u(dir "${dir}")
            endif()
            if(VCPKG_DETECTED_MSVC)
                list(APPEND ${out_var} "-LIBPATH:${dir}")
            else()
                list(APPEND ${out_var} "-L${dir}")
            endif()
        elseif(item MATCHES "^-l(.*)")
            list(APPEND ${out_var} "${item}")
        endif()
    endforeach()
endforeach()

# configuring and building in an autotools-like environment, but using gyp-next and ninja
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    DISABLE_DEFAULT_OPTIONS
    DISABLE_MSVC_WRAPPERS
    DISABLE_MSVC_TRANSFORMATIONS
    OPTIONS
        -g
        -v
        -j "${VCPKG_CONCURRENCY}"
        ${OPTIONS}
        -Ddisable_tests=1
        -Ddisable_werror=1
        -Dsign_libs=0
        -Duse_system_sqlite=1
        -Duse_system_zlib=1
        "--with-nspr=${NSPR_INCLUDE_DIRS}:"
        "-Dsqlite_include_dirs=${SQLITE_INCLUDE_DIRS}"
        "-Dzlib_include_dirs=${ZLIB_INCLUDE_DIRS}"
    OPTIONS_DEBUG
        "-Dnspr_libs=${NSPR_LIBS_DEBUG}"
        "-Dsqlite_libs=${SQLITE_LIBS_DEBUG}"
        "-Dzlib_libs=${ZLIB_LIBS_DEBUG}"
    OPTIONS_RELEASE
        --opt
        "-Dnspr_libs=${NSPR_LIBS_RELEASE}"
        "-Dsqlite_libs=${SQLITE_LIBS_RELEASE}"
        "-Dzlib_libs=${ZLIB_LIBS_RELEASE}"
)

if(NOT VCPKG_BUILD_TYPE)
    set(label "${TARGET_TRIPLET}-dbg")
    set(binary_dir "${CURRENT_BUILDTREES_DIR}/${label}")
    message(STATUS "Installing ${label} ...")
    file(COPY "${binary_dir}/dist/Debug/lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug"
        FILES_MATCHING REGEX "[.](a|dylib|lib|so([.][0-9]+)*)\$"
    )
    file(GLOB runtime_debug "${binary_dir}/dist/Debug/lib/*.dll" "${binary_dir}/dist/Debug/lib/*.pdb")
    if(NOT runtime_debug STREQUAL "")
        file(COPY ${runtime_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

set(label "${TARGET_TRIPLET}-rel")
set(binary_dir "${CURRENT_BUILDTREES_DIR}/${label}")
message(STATUS "Installing ${label} ...")
file(COPY "${binary_dir}/dist/Release/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
    FILES_MATCHING REGEX "[.](a|dylib|lib|so([.][0-9]+)*)\$"
)
file(GLOB runtime_release "${binary_dir}/dist/Release/lib/*.dll" "${binary_dir}/dist/Release/lib/*.pdb")
if(NOT runtime_release STREQUAL "")
    file(COPY ${runtime_release} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(COPY "${binary_dir}/dist/public/nss" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${binary_dir}/dist/private/nss/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/nss/private")

file(READ "${SOURCE_PATH}/nss/pkg/pkg-config/nss.pc.in" pkgconfig)
string(REPLACE "%exec_prefix%" "\${prefix}" pkgconfig "${pkgconfig}")
string(REPLACE "%libdir%" "\${prefix}/lib" pkgconfig "${pkgconfig}")
string(REPLACE "%includedir%" "\${prefix}/include/nss" pkgconfig "${pkgconfig}")
string(REPLACE "%NSS_VERSION%" "${VERSION}" pkgconfig "${pkgconfig}")
string(REPLACE "%NSPR_VERSION%" "4.36" pkgconfig "${pkgconfig}")
string(APPEND pkgconfig "Requires.private: sqlite3\n")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/nss.pc" "${pkgconfig}")
if(NOT VCPKG_BUILD_TYPE)
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/nss.pc" "${pkgconfig}")
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES
        "certutil"
        "cmsutil"
        "crlutil"
        "hw-support"
        "modutil"
        "nss"
        "pk12util"
        "pwdecrypt"
        "shlibsign"
        "signtool"
        "signver"
        "ssltap"
        "symkeyutil"
        "validation"
    SEARCH_DIR "${binary_dir}/dist/Release/bin"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/nss/COPYING")
