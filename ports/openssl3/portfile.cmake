if(EXISTS ${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h)
    message(FATAL_ERROR "Can't build '${PORT}' if another SSL library is installed. Please remove existing one and try install '${PORT}' again if you need it.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openssl/openssl
    REF openssl-3.0.0
    SHA512 50b4fefa3e5a3359e7b06bfbc4ecc525ef9d76e13d087aa8e2d29880f08f74cc9d0c76b9bf1895c118def2bb0e4db0095e799a752b64b60721a423bd2cf989da
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND CONFIGURE_OPTIONS shared)
else()
    list(APPEND CONFIGURE_OPTIONS no-shared)
endif()

# see ${SOURCE_PATH}/INSTALL.md
list(APPEND CONFIGURE_OPTIONS
    no-zlib
    no-ui-console   # Don't build with the User Interface (UI) console method
    no-module       # Don't build any dynamically loadable engines
    no-makedepend   # Don't generate dependencies
    no-tests        # Don't build test programs or run any tests
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND CONFIGURE_OPTIONS no-async)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    # jom will build in parallel mode, we need /FS for PDB access
    list(APPEND CONFIGURE_OPTIONS -utf-8 -FS)

elseif(VCPKG_TARGET_IS_IOS)
    # see https://github.com/microsoft/vcpkg PR 12527
    # disable that makes linkage error (e.g. require stderr usage)
    list(APPEND CONFIGURE_OPTIONS no-stdio no-ui no-asm)

endif()

# Option: platform/architecture. Defined a variable 'PLATFORM'
include(${CMAKE_CURRENT_LIST_DIR}/detect_platform.cmake)

# Clean & copy source files for working directories
file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
)
get_filename_component(SOURCE_DIR_NAME "${SOURCE_PATH}" NAME)
file(COPY        "${SOURCE_PATH}"
     DESTINATION "${CURRENT_BUILDTREES_DIR}")
file(RENAME      "${CURRENT_BUILDTREES_DIR}/${SOURCE_DIR_NAME}"
                 "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
file(COPY        "${SOURCE_PATH}"
     DESTINATION "${CURRENT_BUILDTREES_DIR}")
file(RENAME      "${CURRENT_BUILDTREES_DIR}/${SOURCE_DIR_NAME}"
                 "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

# see ${SOURCE_PATH}/NOTES-PERL.md
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

if(NOT VCPKG_HOST_IS_WINDOWS)
    # see ${SOURCE_PATH}/NOTES-UNIX.md
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH ${MAKE} DIRECTORY)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # see ${SOURCE_PATH}/NOTES-WINDOWS.md
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${NASM_EXE_PATH}")
    # note: jom is not for `vcpkg_add_to_path`
    vcpkg_find_acquire_program(JOM)

elseif(VCPKG_TARGET_IS_ANDROID)
    # see ${SOURCE_PATH}/NOTES-ANDROID.md
    if(NOT DEFINED ENV{ANDROID_NDK_ROOT} AND DEFINED ENV{ANDROID_NDK_HOME})
        set(ENV{ANDROID_NDK_ROOT} $ENV{ANDROID_NDK_HOME})
    endif()
    if(NOT DEFINED ENV{ANDROID_NDK_ROOT})
        message(FATAL_ERROR "ENV{ANDROID_NDK_ROOT} is required by ${SOURCE_PATH}/Configurations/15-android.conf")
    endif()
    if(VCPKG_HOST_IS_LINUX)
        set(NDK_HOST_TAG "linux-x86_64")
    elseif(VCPKG_HOST_IS_OSX)
        set(NDK_HOST_TAG "darwin-x86_64")
    elseif(VCPKG_HOST_IS_WINDOWS)
        set(NDK_HOST_TAG "windows-x86_64")
    else()
        message(FATAL_ERROR "Unknown NDK host platform")
    endif()
    get_filename_component(NDK_TOOL_PATH "$ENV{ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${NDK_HOST_TAG}/bin" ABSOLUTE)
    vcpkg_add_to_path(PREPEND "${NDK_TOOL_PATH}")

endif()

# Configure / Install
# note: we need a PERL so can't use `vcpkg_configure_make` directly...
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PERL} Configure ${OPENSSL_SHARED} ${CONFIGURE_OPTIONS}
                ${PLATFORM} "--prefix=${CURRENT_PACKAGES_DIR}/debug"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME configure-perl-${TARGET_TRIPLET}-dbg
)
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${PERL} Configure ${OPENSSL_SHARED} ${CONFIGURE_OPTIONS}
                ${PLATFORM} "--prefix=${CURRENT_PACKAGES_DIR}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME configure-perl-${TARGET_TRIPLET}-rel
)

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${JOM} /K /J ${VCPKG_CONCURRENCY} /F makefile install_dev
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME install-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${JOM} /K /J ${VCPKG_CONCURRENCY} /F makefile install_dev
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME install-${TARGET_TRIPLET}-rel
    )
    vcpkg_copy_pdbs()

else()
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${MAKE} -j ${VCPKG_CONCURRENCY} install_dev
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME install-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${MAKE} -j ${VCPKG_CONCURRENCY} install_dev
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME install-${TARGET_TRIPLET}-rel
    )
    if(VCPKG_TARGET_IS_ANDROID AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # install_dev copies symbolic link. overwrite them with the actual shared objects
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libcrypto.so"
                     "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libssl.so"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libcrypto.so"
                     "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libssl.so"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )
    endif()
    # rename lib64 to lib for lib/pkgconfig
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib64")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib64" "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib64")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib64" "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    vcpkg_fixup_pkgconfig()

endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libcrypto.a"
                "${CURRENT_PACKAGES_DIR}/debug/lib/libssl.a"
                "${CURRENT_PACKAGES_DIR}/lib/libcrypto.a"
                "${CURRENT_PACKAGES_DIR}/lib/libssl.a"
    )
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin"
                        "${CURRENT_PACKAGES_DIR}/bin"
    )
    if(VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/ossl_static.pdb"
                    "${CURRENT_PACKAGES_DIR}/lib/ossl_static.pdb"
        )
    endif()
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL     "${SOURCE_PATH}/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright"
)
file(INSTALL     "${CURRENT_PORT_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
