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
)
file(COPY "${CURRENT_PORT_DIR}/configure" DESTINATION "${SOURCE_PATH}")

set(gyp_version 0.20.2)
vcpkg_download_distfile(GYP_NEXT_WHEEL
    URLS "https://github.com/nodejs/gyp-next/releases/download/v${gyp_version}/gyp_next-${gyp_version}-py3-none-any.whl"
    FILENAME "gyp_next-${gyp_version}-py3-none-any.whl"
    SHA512 53feff516d0de8738910e04e4e5664af27947c0a2bca856c290f9082d18678b03e917403e2c842edb62b6dd5412c625f34edb52d6d9b295c07ef34b3c18981f8
)
x_vcpkg_get_python_packages(
    OUT_PYTHON_VAR PYTHON3
    PYTHON_VERSION 3
    PACKAGES "${GYP_NEXT_WHEEL}"
)
cmake_path(GET PYTHON3 PARENT_PATH GYP_NEXT_ROOT)

# Prepend to PATH in controlled order
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_ROOT "${NINJA}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NINJA_ROOT}")

find_program(GYP_NEXT NAMES gyp PATHS "${GYP_NEXT_ROOT}" NO_DEFAULT_PATH REQUIRED)
message(STATUS "Using ${GYP_NEXT}")
vcpkg_add_to_path(PREPEND "${GYP_NEXT_ROOT}")

x_vcpkg_pkgconfig_get_modules(PREFIX PC_NSPR MODULES nspr LIBRARIES USE_MSVC_SYNTAX_ON_WINDOWS)
x_vcpkg_pkgconfig_get_modules(PREFIX PC_SQLITE3 MODULES sqlite3 LIBS USE_MSVC_SYNTAX_ON_WINDOWS)
x_vcpkg_pkgconfig_get_modules(PREFIX PC_ZLIB MODULES zlib LIBS USE_MSVC_SYNTAX_ON_WINDOWS)

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
            set(ENV{GYP_MSVS_OVERRIDE_PATH} "${msvs_installdir}")

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

# configuring and building in an autotools-like environment, but using gyp-next and ninja
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    DISABLE_DEFAULT_OPTIONS
    DISABLE_MSVC_WRAPPERS
    DISABLE_MSVC_TRANSFORMATIONS
    OPTIONS
        -g
        -j "${VCPKG_CONCURRENCY}"
        -v
        --disable-tests
        --system-sqlite
        -Ddisable_werror=1
        -Dsign_libs=0
        -Duse_system_zlib=1
        ${OPTIONS}
    OPTIONS_DEBUG
        "--with-nspr=${CURRENT_INSTALLED_DIR}/include/nspr:${CURRENT_INSTALLED_DIR}/debug/lib"
        "-Dnspr_libs=${PC_NSPR_LIBRARIES_DEBUG}"
        "-Dsqlite_libs=${PC_SQLITE3_LIBS_DEBUG}"
        "-Dzlib_libs=${PC_ZLIB_LIBS_DEBUG}"
    OPTIONS_RELEASE
        --opt
        "--with-nspr=${CURRENT_INSTALLED_DIR}/include/nspr:${CURRENT_INSTALLED_DIR}/lib"
        "-Dnspr_libs=${PC_NSPR_LIBRARIES_RELEASE}"
        "-Dsqlite_libs=${PC_SQLITE3_LIBS_RELEASE}"
        "-Dzlib_libs=${PC_ZLIB_LIBS_RELEASE}"
)

if(NOT VCPKG_BUILD_TYPE)
    set(label "${TARGET_TRIPLET}-dbg")
    set(binary_dir "${CURRENT_BUILDTREES_DIR}/${label}")
    message(STATUS "Installing ${label} ...")
    file(COPY "${binary_dir}/dist/Debug/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug" REGEX "[.](a|dylib|lib|so([.][0-9]+)*)\$")
    file(GLOB runtime_debug "${binary_dir}/dist/Debug/lib/*.dll" "${binary_dir}/dist/Debug/lib/*.pdb")
    if(NOT runtime_debug STREQUAL "")
        file(COPY "${runtime_debug}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

set(label "${TARGET_TRIPLET}-rel")
set(binary_dir "${CURRENT_BUILDTREES_DIR}/${label}")
message(STATUS "Installing ${label} ...")
file(COPY "${binary_dir}/dist/Release/lib" DESTINATION "${CURRENT_PACKAGES_DIR}" REGEX "[.](a|dylib|lib|so([.][0-9]+)*)\$")
file(GLOB runtime_release "${binary_dir}/dist/Release/lib/*.dll" "${binary_dir}/dist/Release/lib/*.pdb")
if(NOT runtime_release STREQUAL "")
    file(COPY "${runtime_release}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(COPY "${binary_dir}/dist/public/nss" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${binary_dir}/dist/private/nss/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/nss/private")

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
