set(ICU_VERSION_MAJOR 69)
set(ICU_VERSION_MINOR 1)
set(VERSION "${ICU_VERSION_MAJOR}.${ICU_VERSION_MINOR}")
set(VERSION2 "${ICU_VERSION_MAJOR}_${ICU_VERSION_MINOR}")
set(VERSION3 "${ICU_VERSION_MAJOR}-${ICU_VERSION_MINOR}")

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/unicode-org/icu/releases/download/release-${VERSION3}/icu4c-${VERSION2}-src.tgz"
    FILENAME "icu4c-${VERSION2}-src.tgz"
    SHA512 d4aeb781715144ea6e3c6b98df5bbe0490bfa3175221a1d667f3e6851b7bd4a638fa4a37d4a921ccb31f02b5d15a6dded9464d98051964a86f7b1cde0ff0aab7
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        disable-escapestr-tool.patch
        remove-MD-from-configure.patch
        fix_parallel_build_on_windows.patch
        fix-extra.patch
        mingw-dll-install.patch
        disable-static-prefix.patch # https://gitlab.kitware.com/cmake/cmake/-/issues/16617; also mingw.
        fix-win-build.patch
)

vcpkg_find_acquire_program(PYTHON3)
set(ENV{PYTHON} "${PYTHON3}")

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND CONFIGURE_OPTIONS --enable-icu-build-win)
endif()

list(APPEND CONFIGURE_OPTIONS --disable-samples --disable-tests --disable-layoutex)

list(APPEND CONFIGURE_OPTIONS_RELEASE --disable-debug --enable-release)
list(APPEND CONFIGURE_OPTIONS_DEBUG  --enable-debug --disable-release)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_MINGW AND NOT HOST_TRIPLET MATCHES "mingw")
    # Assuming no cross compiling because the host (windows) pkgdata tool doesn't
    # use the '/' path separator when creating compiler commands for mingw bash.
elseif(VCPKG_CROSSCOMPILING)
    set(TOOL_PATH "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
    # convert to unix path
    string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" _VCPKG_TOOL_PATH "${TOOL_PATH}")
    list(APPEND CONFIGURE_OPTIONS "--with-cross-build=${_VCPKG_TOOL_PATH}")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    PROJECT_SUBPATH source
    OPTIONS ${CONFIGURE_OPTIONS}
    OPTIONS_RELEASE ${CONFIGURE_OPTIONS_RELEASE}
    OPTIONS_DEBUG ${CONFIGURE_OPTIONS_DEBUG}
    DETERMINE_BUILD_TRIPLET
)

if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release"))

    vcpkg_build_make()
    # remove this block if https://unicode-org.atlassian.net/browse/ICU-21458
    # is resolved and use the configure script instead
    if(DEFINED CMAKE_INSTALL_NAME_DIR)
        set(ID_PREFIX "${CMAKE_INSTALL_NAME_DIR}")
    else()
        set(ID_PREFIX "@rpath")
    endif()

    # install_name_tool may be missing if cross-compiling
    find_program(
        INSTALL_NAME_TOOL
        install_name_tool
        HINTS /usr/bin /Library/Developer/CommandLineTools/usr/bin/
        DOC "Absolute path of install_name_tool"
        REQUIRED
    )

    message(STATUS "setting rpath prefix for macOS dynamic libraries")

    # add ID_PREFIX to libicudata libicui18n libicuio libicutu libicuuc
    foreach(LIB_NAME libicudata libicui18n libicuio libicutu libicuuc)
        vcpkg_execute_build_process(
            COMMAND ${INSTALL_NAME_TOOL} -id "${ID_PREFIX}/${LIB_NAME}.${ICU_VERSION_MAJOR}.dylib"
            "${LIB_NAME}.${VERSION}.dylib"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/lib"
            LOGNAME "make-build-fix-rpath-${RELEASE_TRIPLET}"
        )
    endforeach()

    # add ID_PREFIX to libicui18n libicuio libicutu dependencies
    foreach(LIB_NAME libicui18n libicuio)
        vcpkg_execute_build_process(
            COMMAND ${INSTALL_NAME_TOOL} -change "libicuuc.${ICU_VERSION_MAJOR}.dylib"
                                                "${ID_PREFIX}/libicuuc.${ICU_VERSION_MAJOR}.dylib"
                                                "${LIB_NAME}.${VERSION}.dylib"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/lib"
            LOGNAME "make-build-fix-rpath-${RELEASE_TRIPLET}"
        )
        vcpkg_execute_build_process(
            COMMAND ${INSTALL_NAME_TOOL} -change "libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                "${ID_PREFIX}/libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                "${LIB_NAME}.${VERSION}.dylib"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/lib"
            LOGNAME "make-build-fix-rpath-${RELEASE_TRIPLET}"
        )
    endforeach()

    # add ID_PREFIX to remaining libicuio libicutu dependencies
    foreach(LIB_NAME libicuio libicutu)
        vcpkg_execute_build_process(
            COMMAND ${INSTALL_NAME_TOOL} -change "libicui18n.${ICU_VERSION_MAJOR}.dylib"
                                                "${ID_PREFIX}/libicui18n.${ICU_VERSION_MAJOR}.dylib"
                                                "${LIB_NAME}.${VERSION}.dylib"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/lib"
            LOGNAME "make-build-fix-rpath-${RELEASE_TRIPLET}"
        )
    endforeach()

    # add ID_PREFIX to libicuuc dependencies
    vcpkg_execute_build_process(
        COMMAND ${INSTALL_NAME_TOOL} -change "libicudata.${ICU_VERSION_MAJOR}.dylib"
                                            "${ID_PREFIX}/libicudata.${ICU_VERSION_MAJOR}.dylib"
                                            "libicuuc.${VERSION}.dylib"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/lib"
        LOGNAME "make-build-fix-rpath-${RELEASE_TRIPLET}"
    )
endif()

vcpkg_install_make()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/icu"
    "${CURRENT_PACKAGES_DIR}/debug/lib/icu"
    "${CURRENT_PACKAGES_DIR}/debug/lib/icud")

file(GLOB TEST_LIBS
    "${CURRENT_PACKAGES_DIR}/lib/*test*"
    "${CURRENT_PACKAGES_DIR}/debug/lib/*test*")
if(TEST_LIBS)
    file(REMOVE ${TEST_LIBS})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # force U_STATIC_IMPLEMENTATION macro
    foreach(HEADER utypes.h utf_old.h platform.h)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER}" "defined(U_STATIC_IMPLEMENTATION)" "1")
    endforeach()
endif()

# Install executables from /tools/icu/sbin to /tools/icu/bin on unix (/bin because icu require this for cross compiling)
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_copy_tools(
        TOOL_NAMES icupkg gennorm2 gencmn genccode gensprep
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/icu/sbin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/tools/icu/sbin"
    "${CURRENT_PACKAGES_DIR}/tools/icu/debug")

# To cross compile, we need some files at specific positions. So lets copy them
file(GLOB CROSS_COMPILE_DEFS "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/config/icucross.*")
file(INSTALL ${CROSS_COMPILE_DEFS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/config")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*icu*${ICU_VERSION_MAJOR}.dll")
    file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

# copy dlls
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*icu*${ICU_VERSION_MAJOR}.dll")
    file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*icu*${ICU_VERSION_MAJOR}.dll")
    file(COPY ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# remove any remaining dlls in /lib
file(GLOB DUMMY_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DUMMY_DLLS)
    file(REMOVE ${DUMMY_DLLS})
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread m)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/icu/bin/icu-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
