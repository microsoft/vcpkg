
string(REPLACE "." "_" V_URL ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.mozilla.org/pub/security/nss/releases/NSS_${V_URL}_RTM/src/nss-${VERSION}.tar.gz"
    FILENAME "nss-${VERSION}.tar.gz"
    SHA512 4ec7b94e537df109638b821f3a7e3b7bf31d89c3739a6e4c85cad4fab876390ae482971d6f66198818400f467661e86f39dc1d2a4a88077fd81e3a0b7ed64110
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE "${VERSION}"
    PATCHES
        "01-nspr-no-lib-prefix.patch"
        "02-gen-debug-info-for-release.patch"
)

# setup mozbuild for windows
if (VCPKG_TARGET_IS_WINDOWS)
    set(MOZBUILD_ROOT "${CURRENT_HOST_INSTALLED_DIR}/tools/mozbuild")

    set(MOZBUILD_BINDIR "${MOZBUILD_ROOT}/bin")
    vcpkg_add_to_path(PREPEND "${MOZBUILD_BINDIR}")

    set(MOZBUILD_MSYS_ROOT "${MOZBUILD_ROOT}/msys2")
    vcpkg_add_to_path(PREPEND "${MOZBUILD_MSYS_ROOT}/usr/bin")

    # setup mozbuild
    find_program(MOZBUILD_ENV env PATHS "${MOZBUILD_MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    execute_process(
        COMMAND ${MOZBUILD_ENV} mkdir -p /tmp
     )

    find_program(MOZBUILD_BASH bash PATHS "${MOZBUILD_MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    message(STATUS "Found bash: ${MOZBUILD_BASH}")

    # setup mozbuild python
    set(MOZBUILD_PYTHON_ROOT "${MOZBUILD_ROOT}/python3")
    find_program(MOZBUILD_PYTHON python PATHS "${MOZBUILD_PYTHON_ROOT}" NO_DEFAULT_PATH REQUIRED)
    message(STATUS "Found python: ${MOZBUILD_PYTHON}")
    vcpkg_add_to_path(PREPEND "${MOZBUILD_PYTHON_ROOT}")

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

else()
    # TODO: setup non-windows build environment

endif()

# setup gyp-next
set(GYP_NEXT_ROOT "${CURRENT_HOST_INSTALLED_DIR}/tools/gyp-next")
if (VCPKG_HOST_IS_WINDOWS)
    find_file(GYP_NEXT NAMES gyp.bat PATHS "${GYP_NEXT_ROOT}" NO_DEFAULT_PATH REQUIRED)
else()
    find_program(GYP_NEXT NAMES gyp PATHS "${GYP_NEXT_ROOT}" NO_DEFAULT_PATH REQUIRED)
endif()

vcpkg_add_to_path(PREPEND "${GYP_NEXT_ROOT}")
message(STATUS "Found gyp-next: ${GYP_NEXT}")

# setup ninja
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_ROOT "${NINJA}" DIRECTORY)
list(APPEND CMAKE_PROGRAM_PATH "${NINJA_ROOT}")
vcpkg_add_to_path(APPEND "${NINJA_ROOT}")

# setup build.sh options -- see help.txt in nss root
set(OPTIONS
    "-v"
    "-g"
    "--disable-tests"
    "--with-nspr=${VCPKG_INCLUDEDIR}/nspr:${VCPKG_LIBDIR}"
    "--system-sqlite"
    "-Dsign_libs=0"
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND OPTIONS "--target=x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND OPTIONS "--target=ia32")
else()
    message(FATAL_ERROR "Unsupported arch: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS
        "--msvc"
    )

    # prevent homemade vcvarsall.sh from running
    set(VSCOMPONENT "Microsoft.VisualStudio.Component.VC.Tools.x86.x64")
    execute_process(
        COMMAND ${MOZBUILD_ENV} cygpath --unix $ENV{VSINSTALLDIR}
        OUTPUT_VARIABLE GYP_MSVS_OVERRIDE_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    execute_process(
        COMMAND vswhere -latest -requires ${VSCOMPONENT} -property catalog_productLineVersion
        OUTPUT_VARIABLE GYP_MSVS_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    list(APPEND GYPENV
        "VSPATH=${GYP_MSVS_OVERRIDE_PATH}"
        "GYP_MSVS_OVERRIDE_PATH=${GYP_MSVS_OVERRIDE_PATH}"
        "GYP_MSVS_VERSION=${GYP_MSVS_VERSION}"
    )
endif()

#
# get to work
#

set(VCPKG_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

# build debug
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    message(STATUS "Copying sources to debug build dir ...")
    file(COPY "${SOURCE_PATH}/nss" DESTINATION "${VCPKG_BINARY_DIR}-dbg")
    message(STATUS "Building debug ...")
    vcpkg_execute_required_process(
        COMMAND ${MOZBUILD_ENV} ${GYPENV} bash ./build.sh ${OPTIONS}
        WORKING_DIRECTORY ${VCPKG_BINARY_DIR}-dbg/nss
        LOGNAME build-${TARGET_TRIPLET}${short_buildtype}
    )
endif()

# build release
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    message(STATUS "Copying sources to release build dir ...")
    file(COPY "${SOURCE_PATH}/nss" DESTINATION "${VCPKG_BINARY_DIR}-rel")
    message(STATUS "Building release ...")
    vcpkg_execute_required_process(
        COMMAND ${MOZBUILD_ENV} ${GYPENV} bash ./build.sh ${OPTIONS} --opt
        WORKING_DIRECTORY ${VCPKG_BINARY_DIR}-rel/nss
        LOGNAME build-${TARGET_TRIPLET}${short_buildtype}
    )
endif()

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
        file(RENAME "${path}" "${CURRENT_PACKAGES_DIR}/bin/${name}")
    endforeach()

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${VCPKG_BINARY_DIR}-rel/dist/Release/lib" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()

# Tools from the release build
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
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB LIB_DEBUG
        "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib/*.dll"
        "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib/*.pdb"
    )
    list(LENGTH LIB_DEBUG LIB_DEBUG_SIZE)

    if (LIB_DEBUG_SIZE GREATER 0)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

        foreach(path ${LIB_DEBUG})
            get_filename_component(name "${path}" NAME)
            file(RENAME "${path}" "${CURRENT_PACKAGES_DIR}/debug/bin/${name}")
        endforeach()

        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(COPY "${VCPKG_BINARY_DIR}-dbg/dist/Debug/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
    endif()
endif()

# License
file(INSTALL "${SOURCE_PATH}/nss/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nss" RENAME copyright)
