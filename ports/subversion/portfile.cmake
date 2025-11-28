vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/subversion
    REF "${VERSION}"
    SHA512 cc42f90e8a3a5df8a27c10ffd8f271292c5f3309e4efdcd1a9fb94f93689fb90b96c39bff8a4bd6fd2229cca32ce1baf6d5a6237d3427a1fb7130898698d17c3
    HEAD_REF trunk
    PATCHES
        vcpkg-expat-regex.patch
)
    
if(VERSION VERSION_GREATER_EQUAL "1.15.0")
    set(USE_CMAKE_BUILD TRUE)
else()
    set(USE_CMAKE_BUILD FALSE)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bdb     ENABLE_BDB
        nls     ENABLE_NLS
        sasl    ENABLE_SASL
        tools   ENABLE_TOOLS
)

if(USE_CMAKE_BUILD)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} gen-make.py -t cmake
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "gen-make-${TARGET_TRIPLET}"
    )
    
    set(CMAKE_OPTIONS
        -DSVN_ENABLE_PROGRAMS=${ENABLE_TOOLS}
        -DSVN_ENABLE_TESTS=OFF
        -DSVN_ENABLE_RA_SERF=ON
        -DSVN_ENABLE_RA_SVN=ON
        -DSVN_ENABLE_RA_LOCAL=ON
    )
    
    if(ENABLE_BDB)
        list(APPEND CMAKE_OPTIONS -DSVN_ENABLE_FS_BASE=ON)
    endif()
    
    if(ENABLE_NLS)
        list(APPEND CMAKE_OPTIONS -DSVN_ENABLE_NLS=ON)
    endif()
    
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS ${CMAKE_OPTIONS}
    )
    
    vcpkg_cmake_install()
    vcpkg_cmake_fixup(CONFIG_PATH lib/cmake/subversion)
    vcpkg_copy_pdbs()
    
    if(ENABLE_TOOLS)
        vcpkg_copy_tools(
            TOOL_NAMES svn svnadmin svnlook svnsync svnrdump svnmucc svnserve
            AUTO_CLEAN
        )
    endif()
    
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

    if(ENABLE_BDB)
        list(APPEND GEN_MAKE_ARGS "--with-berkeley-db=${CURRENT_INSTALLED_DIR}")
    endif()

    if(ENABLE_SASL)
        list(APPEND GEN_MAKE_ARGS "--with-sasl=${CURRENT_INSTALLED_DIR}")
    endif()

    if(ENABLE_NLS)
        list(APPEND GEN_MAKE_ARGS "--with-libintl=${CURRENT_INSTALLED_DIR}")
    endif()

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
        RELEASE_CONFIGURATION "Release"
        DEBUG_CONFIGURATION "Debug"
        OPTIONS "/p:Platform=${VCPKG_TARGET_ARCHITECTURE}"
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

    if(ENABLE_TOOLS AND (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release"))
        file(GLOB TOOLS "${SOURCE_PATH}/Release/subversion/svn/*.exe" 
                        "${SOURCE_PATH}/Release/subversion/svnadmin/*.exe"
                        "${SOURCE_PATH}/Release/subversion/svnserve/*.exe"
                        "${SOURCE_PATH}/Release/subversion/svnlook/*.exe"
                        "${SOURCE_PATH}/Release/subversion/svnsync/*.exe"
                        "${SOURCE_PATH}/Release/subversion/svnrdump/*.exe"
                        "${SOURCE_PATH}/Release/subversion/svnmucc/*.exe")
        if(TOOLS)
            file(INSTALL ${TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/subversion")
            vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/subversion")
        endif()
    endif()

else()
    set(CONFIGURE_OPTIONS
        --with-apr=${CURRENT_INSTALLED_DIR}
        --with-apr-util=${CURRENT_INSTALLED_DIR}
        --with-serf=${CURRENT_INSTALLED_DIR}
        --with-zlib=${CURRENT_INSTALLED_DIR}
        --with-lz4=internal
        --with-utf8proc=internal
        --without-swig
        --without-jdk
        --disable-mod-activation
    )

    if(ENABLE_BDB)
        list(APPEND CONFIGURE_OPTIONS "--with-berkeley-db=${CURRENT_INSTALLED_DIR}")
    else()
        list(APPEND CONFIGURE_OPTIONS "--without-berkeley-db")
    endif()

    if(ENABLE_NLS)
        list(APPEND CONFIGURE_OPTIONS "--enable-nls")
    else()
        list(APPEND CONFIGURE_OPTIONS "--disable-nls")
    endif()

    if(ENABLE_SASL)
        list(APPEND CONFIGURE_OPTIONS "--with-sasl=${CURRENT_INSTALLED_DIR}")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${CONFIGURE_OPTIONS}
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
endif()

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-subversion-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-subversion"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()
