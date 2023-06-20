string(REGEX MATCH "^[0-9]*" ICU_VERSION_MAJOR "${VERSION}")
string(REPLACE "." "_" VERSION2 "${VERSION}")
string(REPLACE "." "-" VERSION3 "${VERSION}")

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/unicode-org/icu/releases/download/release-${VERSION3}/icu4c-${VERSION2}-src.tgz"
    FILENAME "icu4c-${VERSION2}-src.tgz"
    SHA512 e788e372716eecebc39b56bbc88f3a458e21c3ef20631c2a3d7ef05794a678fe8dad482a03a40fdb9717109a613978c7146682e98ee16fade5668d641d5c48f8
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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

if("tools" IN_LIST FEATURES)
  list(APPEND CONFIGURE_OPTIONS --enable-tools)
else()
  list(APPEND CONFIGURE_OPTIONS --disable-tools)
endif()
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
    ADDITIONAL_MSYS_PACKAGES autoconf-archive
    OPTIONS ${CONFIGURE_OPTIONS}
    OPTIONS_RELEASE ${CONFIGURE_OPTIONS_RELEASE}
    OPTIONS_DEBUG ${CONFIGURE_OPTIONS_DEBUG}
    DETERMINE_BUILD_TRIPLET
)

if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")

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

    if("tools" IN_LIST FEATURES)
        set(LIBICUTU_RPATH "libicutu")
    endif()

    #31680: Fix @rpath in both debug and release build
    foreach(CONFIG_TRIPLE IN ITEMS ${DEBUG_TRIPLET} ${RELEASE_TRIPLET})
        # add ID_PREFIX to libicudata libicui18n libicuio libicutu libicuuc
        foreach(LIB_NAME IN ITEMS libicudata libicui18n libicuio ${LIBICUTU_RPATH} libicuuc)
            vcpkg_execute_build_process(
                COMMAND "${INSTALL_NAME_TOOL}" -id "${ID_PREFIX}/${LIB_NAME}.${ICU_VERSION_MAJOR}.dylib"
                "${LIB_NAME}.${VERSION}.dylib"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${CONFIG_TRIPLE}/lib"
                LOGNAME "make-build-fix-rpath-${CONFIG_TRIPLE}"
            )
        endforeach()

        # add ID_PREFIX to libicui18n libicuio libicutu dependencies
        foreach(LIB_NAME IN ITEMS libicui18n libicuio)
            vcpkg_execute_build_process(
                COMMAND "${INSTALL_NAME_TOOL}" -change "libicuuc.${ICU_VERSION_MAJOR}.dylib"
                                                    "${ID_PREFIX}/libicuuc.${ICU_VERSION_MAJOR}.dylib"
                                                    "${LIB_NAME}.${VERSION}.dylib"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${CONFIG_TRIPLE}/lib"
                LOGNAME "make-build-fix-rpath-${CONFIG_TRIPLE}"
            )
            vcpkg_execute_build_process(
                COMMAND "${INSTALL_NAME_TOOL}" -change "libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                    "${ID_PREFIX}/libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                    "${LIB_NAME}.${VERSION}.dylib"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${CONFIG_TRIPLE}/lib"
                LOGNAME "make-build-fix-rpath-${CONFIG_TRIPLE}"
            )
        endforeach()

        # add ID_PREFIX to remaining libicuio libicutu dependencies
        foreach(LIB_NAME libicuio libicutu)
            vcpkg_execute_build_process(
                COMMAND "${INSTALL_NAME_TOOL}" -change "libicui18n.${ICU_VERSION_MAJOR}.dylib"
                                                    "${ID_PREFIX}/libicui18n.${ICU_VERSION_MAJOR}.dylib"
                                                    "${LIB_NAME}.${VERSION}.dylib"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${CONFIG_TRIPLE}/lib"
                LOGNAME "make-build-fix-rpath-${CONFIG_TRIPLE}"
            )
        endforeach()

        # add ID_PREFIX to libicuuc dependencies
        vcpkg_execute_build_process(
            COMMAND "${INSTALL_NAME_TOOL}" -change "libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                "${ID_PREFIX}/libicudata.${ICU_VERSION_MAJOR}.dylib"
                                                "libicuuc.${VERSION}.dylib"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${CONFIG_TRIPLE}/lib"
            LOGNAME "make-build-fix-rpath-${CONFIG_TRIPLE}"
        )
    endforeach()

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
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX AND "tools" IN_LIST FEATURES)
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

file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*icu*${ICU_VERSION_MAJOR}.dll")
file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

# copy dlls
file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*icu*${ICU_VERSION_MAJOR}.dll")
file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
if(NOT VCPKG_BUILD_TYPE)
    file(GLOB DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*icu*${ICU_VERSION_MAJOR}.dll")
    file(COPY ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# remove any remaining dlls in /lib
file(GLOB DUMMY_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DUMMY_DLLS)
    file(REMOVE ${DUMMY_DLLS})
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/icu/bin/icu-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
