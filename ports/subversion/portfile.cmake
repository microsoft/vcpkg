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

if(VERSION VERSION_GREATER_EQUAL "1.15.0")
    set(USE_CMAKE_BUILD TRUE)
else()
    set(USE_CMAKE_BUILD FALSE)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(USE_CMAKE_BUILD)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} gen-make.py -t cmake
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "gen-make-${TARGET_TRIPLET}"
    )

    set(CMAKE_OPTIONS
        -DSVN_ENABLE_PROGRAMS=OFF
        -DSVN_ENABLE_TESTS=OFF
        -DSVN_ENABLE_RA_SERF=ON
        -DSVN_ENABLE_RA_SVN=ON
        -DSVN_ENABLE_RA_LOCAL=ON
    )

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS ${CMAKE_OPTIONS}
    )

    vcpkg_cmake_install()
    vcpkg_cmake_fixup(CONFIG_PATH lib/cmake/subversion)
    vcpkg_copy_pdbs()

elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v143")
        set(VSNET_VERSION "2022")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(VSNET_VERSION "2019")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(VSNET_VERSION "2017")
    else()
        set(VSNET_VERSION "2022")
    endif()

    set(GEN_MAKE_ARGS
        "-t" "vcproj"
        "--vsnet-version=${VSNET_VERSION}"
        "--with-apr=${CURRENT_INSTALLED_DIR}"
        "--with-apr-util=${CURRENT_INSTALLED_DIR}"
        "--with-zlib=${CURRENT_INSTALLED_DIR}"
        "--with-openssl=${CURRENT_INSTALLED_DIR}"
        "--with-serf=${CURRENT_INSTALLED_DIR}"
        "--with-sqlite=${CURRENT_INSTALLED_DIR}"
    )
    
    # ICU is required because sqlite3 is built with unicode support
    find_package(ICU COMPONENTS uc i18n dt REQUIRED)

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
    
    # Build MSBuild options - add ICU libraries for x64-windows-static-md
    set(MSBUILD_OPTIONS "/p:Platform=${VCPKG_TARGET_ARCHITECTURE}")
    if(VCPKG_TARGET_TRIPLET STREQUAL "x64-windows-static-md")
        # SQLite3 is built with ICU support, so we need to link ICU libraries
        string(APPEND MSBUILD_OPTIONS " \"/p:AdditionalDependencies=icuuc.lib;icuin.lib;icudt.lib;%(AdditionalDependencies)\"")
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "subversion_vcnet.sln"
        TARGET "Rebuild"
        RELEASE_CONFIGURATION "Release"
        DEBUG_CONFIGURATION "Debug"
        OPTIONS ${MSBUILD_OPTIONS}
    )

    file(INSTALL "${SOURCE_PATH}/subversion/include/"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/subversion-1"
        FILES_MATCHING PATTERN "*.h"
    )

    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB RELEASE_LIBS "${SOURCE_PATH}/Release/subversion/libsvn_*/*.lib")
        list(FILTER RELEASE_LIBS EXCLUDE REGEX "libsvn_test")
        file(INSTALL ${RELEASE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(GLOB RELEASE_DLLS "${SOURCE_PATH}/Release/subversion/libsvn_*/*.dll")
            file(INSTALL ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()

    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
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
        OPTIONS
            ${CONFIGURE_OPTIONS}
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