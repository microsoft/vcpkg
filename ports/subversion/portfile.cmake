vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/subversion
    REF "${VERSION}"
    SHA512 cc42f90e8a3a5df8a27c10ffd8f271292c5f3309e4efdcd1a9fb94f93689fb90b96c39bff8a4bd6fd2229cca32ce1baf6d5a6237d3427a1fb7130898698d17c3
    HEAD_REF trunk
    PATCHES
        fix-expat-regex.patch
        fix-expat-libname.patch
        fix-sysinfo-linux.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_WINDOWS)
    set(GEN_MAKE_ARGS
        "-t" "vcproj"
        "--vsnet-version=2022"
        "--with-apr=${CURRENT_INSTALLED_DIR}"
        "--with-apr-util=${CURRENT_INSTALLED_DIR}"
        "--with-zlib=${CURRENT_INSTALLED_DIR}"
        "--with-openssl=${CURRENT_INSTALLED_DIR}"
        "--with-serf=${CURRENT_INSTALLED_DIR}"
        "--with-sqlite=${CURRENT_INSTALLED_DIR}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND GEN_MAKE_ARGS "--disable-shared")
        list(APPEND GEN_MAKE_ARGS "--with-static-apr")
        list(APPEND GEN_MAKE_ARGS "--with-static-openssl")
    endif()

    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} gen-make.py ${GEN_MAKE_ARGS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "gen-make-${TARGET_TRIPLET}"
    )

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "subversion_vcnet.sln"
        TARGET "Rebuild"
    )

    file(INSTALL "${SOURCE_PATH}/subversion/include/"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/subversion-1"
        FILES_MATCHING PATTERN "*.h"
    )

    if(EXISTS "${SOURCE_PATH}/Release/subversion")
        file(GLOB RELEASE_LIBS "${SOURCE_PATH}/Release/subversion/libsvn_*/*.lib")
        list(FILTER RELEASE_LIBS EXCLUDE REGEX "libsvn_test")
        file(INSTALL ${RELEASE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(GLOB RELEASE_DLLS "${SOURCE_PATH}/Release/subversion/libsvn_*/*.dll")
            file(INSTALL ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()

    if(EXISTS "${SOURCE_PATH}/Debug/subversion")
        file(GLOB DEBUG_LIBS "${SOURCE_PATH}/Debug/subversion/libsvn_*/*.lib")
        list(FILTER DEBUG_LIBS EXCLUDE REGEX "libsvn_test")
        file(INSTALL ${DEBUG_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(GLOB DEBUG_DLLS "${SOURCE_PATH}/Debug/subversion/libsvn_*/*.dll")
            file(INSTALL ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()

else()
    set(CONFIGURE_OPTIONS
        --with-apr=${CURRENT_INSTALLED_DIR}/tools/apr
        --with-apr-util=${CURRENT_INSTALLED_DIR}/tools/apr-util
        --with-serf=${CURRENT_INSTALLED_DIR}
        --with-lz4=internal
        --with-utf8proc=internal
        --without-swig
        --without-jdk
        --disable-mod-activation
        --without-berkeley-db
        --disable-nls
    )

    vcpkg_execute_required_process(
        COMMAND bash -c "PYTHON=python3 ./autogen.sh"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "autogen-${TARGET_TRIPLET}"
    )

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        ADD_BIN_TO_PATH
        OPTIONS ${CONFIGURE_OPTIONS}
    )

    vcpkg_install_make()
    
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/subversion/pkgconfig")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        file(GLOB PC_FILES "${CURRENT_PACKAGES_DIR}/share/subversion/pkgconfig/*.pc")
        file(COPY ${PC_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/subversion/pkgconfig")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/subversion/pkgconfig")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
        file(GLOB PC_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/share/subversion/pkgconfig/*.pc")
        file(COPY ${PC_FILES_DBG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/subversion/pkgconfig")
    endif()
    
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-subversion-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-subversion"
)

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")