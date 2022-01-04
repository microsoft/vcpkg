set(NSS_VERSION "3.73.1")
string(REPLACE "." "_" V_URL ${NSS_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.mozilla.org/pub/security/nss/releases/NSS_${V_URL}_RTM/src/nss-${NSS_VERSION}.tar.gz"
    FILENAME "nss-${NSS_VERSION}.tar.gz"
    SHA512 4cca26cb430f1c167ce7c3a2654c1315938c73bbd425c89d4e636a966fd052724499f34affc5764ec680eeaa080892caab28ef00fe21992421c739f7623cf071
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF "${NSS_VERSION}"
    PATCHES "01-nspr-no-lib-prefix.patch"
)

# setup ninja
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_ROOT "${NINJA}" DIRECTORY)
list(APPEND CMAKE_PROGRAM_PATH "${NINJA_ROOT}")
vcpkg_add_to_path(APPEND "${NINJA_ROOT}")

# setup mozbuild
vcpkg_find_acquire_program(MOZBUILD)
get_filename_component(MOZBUILD_ROOT ${MOZBUILD} DIRECTORY)
get_filename_component(MOZBUILD_ROOT "${MOZBUILD_ROOT}" PATH)
if (VCPKG_TARGET_IS_WINDOWS)
    set(MOZBUILD_BINDIR "${MOZBUILD_ROOT}/bin")
    vcpkg_add_to_path(PREPEND "${MOZBUILD_BINDIR}")

    set(MOZBUILD_MSYS_ROOT "${MOZBUILD_ROOT}/msys")
    vcpkg_add_to_path(PREPEND "${MOZBUILD_MSYS_ROOT}/bin")

    find_program(MOZBUILD_MAKE_COMMAND make PATHS "${MOZBUILD_MSYS_ROOT}/bin" NO_DEFAULT_PATH REQUIRED)
    message(STATUS "Found make: ${MOZBUILD_MAKE_COMMAND}")

    find_program(MOZBUILD_BASH         bash PATHS "${MOZBUILD_MSYS_ROOT}/bin" NO_DEFAULT_PATH REQUIRED)
    message(STATUS "Found bash: ${MOZBUILD_BASH}")
endif()

set(MOZBUILD_PYTHON_ROOT "${MOZBUILD_ROOT}/python")
find_program(MOZBUILD_PYTHON     python PATHS "${MOZBUILD_ROOT}/python" NO_DEFAULT_PATH REQUIRED)
message(STATUS "Found python: ${MOZBUILD_PYTHON}")
vcpkg_add_to_path(PREPEND "${MOZBUILD_PYTHON_ROOT}")

vcpkg_find_acquire_program(GYP)
get_filename_component(GYP_ROOT ${GYP} DIRECTORY)
vcpkg_add_to_path(PREPEND "${GYP_ROOT}")
message("GYP_ROOT: ${GYP_ROOT}")

# setup paths
execute_process(
    COMMAND ${MOZBUILD_BASH} -c pwd
    WORKING_DIRECTORY ${CURRENT_INSTALLED_DIR}/include
    OUTPUT_VARIABLE VCPKG_INCLUDEDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Using headers from: ${VCPKG_INCLUDEDIR} arch: ${VCPKG_TARGET_ARCHITECTURE}")

execute_process(
    COMMAND ${MOZBUILD_BASH} -c pwd
    WORKING_DIRECTORY ${CURRENT_INSTALLED_DIR}/lib
    OUTPUT_VARIABLE VCPKG_LIBDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Using libraries from: ${VCPKG_LIBDIR} arch: ${VCPKG_TARGET_ARCHITECTURE}")

#
# get to work
#

# see help.txt in nss root
set(OPTIONS
    "-v" "-g"
    "--disable-tests"
    "--with-nspr=${VCPKG_INCLUDEDIR}:${VCPKG_LIBDIR}"
    "--system-sqlite"
    "-Dsign_libs=0"
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND OPTIONS "--target=x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND OPTIONS "--target=ia32")
else()
    message(FATAL "Unsupported arch: %{VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS
        "--msvc"
    )
endif()

set(VCPKG_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

message(STATUS "Copying sources to build dirs ...")
file(COPY "${SOURCE_PATH}/nss" DESTINATION "${VCPKG_BINARY_DIR}-dbg")
file(COPY "${SOURCE_PATH}/nss" DESTINATION "${VCPKG_BINARY_DIR}-rel")

message(STATUS "Building debug ...")
vcpkg_execute_required_process(
    COMMAND ${MOZBUILD_BASH} ./build.sh ${OPTIONS}
    WORKING_DIRECTORY ${VCPKG_BINARY_DIR}-dbg/nss
    LOGNAME build-${TARGET_TRIPLET}${short_buildtype}
)

message(STATUS "Building release ...")
vcpkg_execute_required_process(
    COMMAND ${MOZBUILD_BASH} ./build.sh ${OPTIONS} "--opt"
    WORKING_DIRECTORY ${VCPKG_BINARY_DIR}-rel/nss
    LOGNAME build-${TARGET_TRIPLET}${short_buildtype}
)
#
# VCPKG FHS adjustments
#

# Headers

file(
    COPY "${VCPKG_BINARY_DIR}-rel/dist/public/nss"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(
    COPY "${VCPKG_BINARY_DIR}-rel/dist/private/nss/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/nss/private"
)

# Release libraries

file(GLOB LIB_RELEASE
    "${VCPKG_BINARY_DIR}-rel/dist/Release/lib/*.dll"
    "${VCPKG_BINARY_DIR}-rel/dist/Release/lib/*.pdb"
)
list(LENGTH LIB_RELEASE LIB_RELEASE_SIZE)

if (LIB_RELEASE_SIZE GREATER 0)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")

    foreach(path ${LIB_RELEASE})
        get_filename_component(name "${path}" NAME)
        file(RENAME "${path}"        "${CURRENT_PACKAGES_DIR}/bin/${name}")
    endforeach()

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${VCPKG_BINARY_DIR}-rel/dist/Release/lib" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()

# Release tools

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
    
    SEARCH_DIR "${VCPKG_BINARY_DIR}-rel/dist/Release/bin/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)

# Debug libraries

file(GLOB LIB_DEBUG
    "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib/*.dll"
    "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib/*.pdb"
)
list(LENGTH LIB_DEBUG LIB_DEBUG_SIZE)

if (LIB_DEBUG_SIZE GREATER 0)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

    foreach(path ${LIB_DEBUG})
        get_filename_component(name "${path}" NAME)
        file(RENAME "${path}"        "${CURRENT_PACKAGES_DIR}/debug/bin/${name}")
    endforeach()

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Debug tools

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
    
    SEARCH_DIR "${VCPKG_BINARY_DIR}-dbg/dist/Debug/bin/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
)

# Copy license

file(COPY "${SOURCE_PATH}/nss/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nss")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/nss/COPYING" "${CURRENT_PACKAGES_DIR}/share/nss/copyright")
