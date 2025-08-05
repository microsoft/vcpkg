include("${CMAKE_CURRENT_LIST_DIR}/tgfx-functions.cmake")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Tencent/tgfx
        REF 0d875c4da20882c172c707b5237759dc3a543178
        SHA512 7672f53239896910a1a3939cd364aa8e84d8c3865aed12296fcb79fbf91e60ad05d5238062e0ac9cde3e16325cfe3a2e645efc31d21531763af495a38c959343
        PATCHES
            disable-depsync.patch
)

parse_and_declare_deps_externals("${SOURCE_PATH}")
get_tgfx_externals("${SOURCE_PATH}")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
endif()
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

find_program(NODEJS
        NAMES node
        PATHS
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node"
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin"
        ENV PATH
        NO_DEFAULT_PATH
)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")

find_program(NINJA
        NAMES ninja
        PATHS
        "${CURRENT_HOST_INSTALLED_DIR}/tools/ninja"
        ENV PATH
        NO_DEFAULT_PATH
)
if(NOT NINJA)
    message(FATAL_ERROR "ninja not found! Please install it via your system package manager!")
endif()

get_filename_component(NINJA_DIR "${NINJA}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NINJA_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
        svg             TGFX_BUILD_SVG
        layers          TGFX_BUILD_LAYERS
        qt              TGFX_USE_QT
        swiftshader     TGFX_USE_SWIFTSHADER
        angle           TGFX_USE_ANGLE
        async-promise   TGFX_USE_ASYNC_PROMISE
)

set(PLATFORM_OPTIONS)

if(VCPKG_TARGET_IS_ANDROID)
    if(NOT VCPKG_DETECTED_CMAKE_ANDROID_NDK)
        message(FATAL_ERROR "Android NDK not detected. Please set ANDROID_NDK_HOME")
    endif()

    list(APPEND PLATFORM_OPTIONS
            -DCMAKE_ANDROID_NDK=${VCPKG_DETECTED_CMAKE_ANDROID_NDK}
            -DCMAKE_ANDROID_API=${VCPKG_DETECTED_CMAKE_SYSTEM_VERSION}
            -DCMAKE_ANDROID_ARCH_ABI=${VCPKG_TARGET_ARCHITECTURE}
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_PLATFORM_TOOLSET VERSION_LESS "v142")
        message(WARNING "TGFX requires Visual Studio 2019+ for optimal C++17 support")
    endif()
endif()

#if(VCPKG_DETECTED_CMAKE_C_COMPILER)
#    string(REPLACE " " "\\ " ESCAPED_C_COMPILER "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
#    list(APPEND PLATFORM_OPTIONS "-DCMAKE_C_COMPILER=\"${ESCAPED_C_COMPILER}\"")
#endif()
#if(VCPKG_DETECTED_CMAKE_CXX_COMPILER)
#    string(REPLACE " " "\\ " ESCAPED_CXX_COMPILER "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
#    list(APPEND PLATFORM_OPTIONS "-DCMAKE_CXX_COMPILER=\"${ESCAPED_CXX_COMPILER}\"")
#endif()

set(BASE_BUILD_ARGS "")

foreach(option IN LISTS FEATURE_OPTIONS)
    if(option MATCHES "^-D(.+)=(.+)$")
        list(APPEND BASE_BUILD_ARGS "-D${CMAKE_MATCH_1}=${CMAKE_MATCH_2}")
    elseif(option MATCHES "^-D(.+)$")
        list(APPEND BASE_BUILD_ARGS "-D${CMAKE_MATCH_1}=ON")
    endif()
endforeach()

foreach(option IN LISTS PLATFORM_OPTIONS)
    if(option MATCHES "^-D(.+)=(.+)$")
        list(APPEND BASE_BUILD_ARGS "-D${CMAKE_MATCH_1}=${CMAKE_MATCH_2}")
    elseif(option MATCHES "^-D(.+)$")
        list(APPEND BASE_BUILD_ARGS "-D${CMAKE_MATCH_1}=ON")
    endif()
endforeach()

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(CMAKE_OSX_SYSROOT_INT "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    set(SDK_VERSION "")
    find_program(XCODEBUILD_EXECUTABLE xcodebuild)
    if(XCODEBUILD_EXECUTABLE AND NOT CMAKE_OSX_SYSROOT_INT)
        vcpkg_execute_required_process(
                COMMAND ${XCODEBUILD_EXECUTABLE} -sdk ${CMAKE_OSX_SYSROOT_INT} -version
                WORKING_DIRECTORY ${SOURCE_PATH}
                LOGNAME "xcodebuild-sdk-version"
                OUTPUT_VARIABLE xcodebuild_output
        )
        if(xcodebuild_output)
            if(VCPKG_TARGET_IS_OSX)
                string(REGEX MATCH "MacOSX([0-9]+\\.[0-9]+)" _ "${xcodebuild_output}")
                set(SDK_VERSION "${CMAKE_MATCH_1}")
                if(NOT CMAKE_OSX_SYSROOT_INT)
                    string(REGEX MATCH "Path: ([^\n]*MacOSX[0-9.]+\.sdk)" _ "${xcodebuild_output}")
                    set(CMAKE_OSX_SYSROOT_INT "${CMAKE_MATCH_1}")
                endif ()
            elseif(VCPKG_TARGET_IS_IOS)
                string(REGEX MATCH "iPhone(OS|Simulator)([0-9]+\\.[0-9]+)" _ "${xcodebuild_output}")
                set(SDK_VERSION "${CMAKE_MATCH_2}")
                if(NOT CMAKE_OSX_SYSROOT_INT)
                    string(REGEX MATCH "Path: ([^\n]*iPhone(OS|Simulator)[0-9.]+\.sdk)" _ "${xcodebuild_output}")
                    set(CMAKE_OSX_SYSROOT_INT "${CMAKE_MATCH_1}")
                endif ()
            endif ()
        endif ()
    endif()
    if(CMAKE_OSX_SYSROOT_INT AND NOT SDK_VERSION)
        if(VCPKG_TARGET_IS_OSX)
            string(REGEX MATCH "MacOSX([0-9]+\\.[0-9]+)" _ "${CMAKE_OSX_SYSROOT_INT}")
            set(SDK_VERSION "${CMAKE_MATCH_1}")
        elseif(VCPKG_TARGET_IS_IOS)
            string(REGEX MATCH "iPhone(OS|Simulator)([0-9]+\\.[0-9]+)" _ "${CMAKE_OSX_SYSROOT_INT}")
            set(SDK_VERSION "${CMAKE_MATCH_2}")
        endif ()
    endif()
    if(NOT SDK_VERSION AND NOT CMAKE_OSX_SYSROOT_INT)
        message(FATAL_ERROR "Unable to extract SDK path and SDK version.")
    endif()
    set(ENV{_CMAKE_OSX_SYSROOT_INT} "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    set(ENV{_SDK_VERSION} "${SDK_VERSION}")
endif()

set(ENV{CMAKE_COMMAND} "${CMAKE_COMMAND}")
set(ENV{CMAKE_PREFIX_PATH} "${CURRENT_INSTALLED_DIR}")

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            ${BASE_BUILD_ARGS}
            -DTGFX_BUILD_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/tgfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
