include("${CMAKE_CURRENT_LIST_DIR}/tgfx-functions.cmake")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Tencent/tgfx
        REF bb753b09d58557617206a6bdfc612907bd2100d8
        SHA512 732489af152f69c94590e349a2090910440aa5d2d63cec8dd0879c03764e147856d2bee10c5b62dcf8adb2c52ae8d02ad710efd8d4f8f2f092790c48ebd1c088
)

parse_and_declare_deps_externals("${SOURCE_PATH}")
get_tgfx_external_from_git("${SOURCE_PATH}")

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
            -DANDROID=TRUE
    )
elseif(VCPKG_CMAKE_SYSTEM_NAME MATCHES "OHOS")
    # 查找鸿蒙SDK路径，支持多种环境变量命名
    set(OHOS_SDK_ROOT "")
    
    if(DEFINED ENV{OHOS_SDK_HOME})
        set(OHOS_SDK_ROOT $ENV{OHOS_SDK_HOME})
    elseif(DEFINED ENV{OHOS_NDK_HOME})
        set(OHOS_SDK_ROOT $ENV{OHOS_NDK_HOME})
    elseif(DEFINED ENV{CMAKE_OHOS_NDK})
        set(OHOS_SDK_ROOT $ENV{CMAKE_OHOS_NDK})
    elseif(DEFINED ENV{OHOS_SDK})
        set(OHOS_SDK_ROOT $ENV{OHOS_SDK})
    elseif(DEFINED ENV{HARMONY_SDK_HOME})
        set(OHOS_SDK_ROOT $ENV{HARMONY_SDK_HOME})
    else()
        message(FATAL_ERROR "HarmonyOS SDK not detected. Please set one of the following environment variables:\n"
                            "  OHOS_SDK_HOME (recommended)\n"
                            "  OHOS_NDK_HOME\n"
                            "  CMAKE_OHOS_NDK\n"
                            "  OHOS_SDK\n"
                            "  HARMONY_SDK_HOME")
    endif()

    if(NOT EXISTS "${OHOS_SDK_ROOT}")
        message(FATAL_ERROR "OHOS SDK path does not exist: ${OHOS_SDK_ROOT}")
    endif()

    if(NOT EXISTS "${OHOS_SDK_ROOT}/native")
        message(FATAL_ERROR "Invalid OHOS SDK structure. Missing 'native' directory in: ${OHOS_SDK_ROOT}")
    endif()

    set(OHOS_NDK_PATH "${OHOS_SDK_ROOT}/native")

    if(NOT EXISTS "${OHOS_NDK_PATH}/sysroot")
        message(FATAL_ERROR "Could not find OHOS sysroot at ${OHOS_NDK_PATH}/sysroot")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OHOS_ARCH_DIR "x86_64-linux-ohos")
        set(OHOS_ARCH_VALUE "x86_64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(OHOS_ARCH_DIR "aarch64-linux-ohos")
        set(OHOS_ARCH_VALUE "arm64-v8a")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(OHOS_ARCH_DIR "arm-linux-ohos")
        set(OHOS_ARCH_VALUE "arm")
    else()
        message(FATAL_ERROR "Invalid architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    message(STATUS "Using OHOS SDK: ${OHOS_SDK_ROOT}")
    message(STATUS "Using OHOS NDK: ${OHOS_NDK_PATH}")
    message(STATUS "Using OHOS Architecture: ${OHOS_ARCH_VALUE} (${OHOS_ARCH_DIR})")

    list(APPEND PLATFORM_OPTIONS
        "-DOHOS=TRUE"
        "-DOHOS_ARCH=${OHOS_ARCH_VALUE}"
        "-DOHOS_PLATFORM=OHOS"
        "-DOHOS_SDK_HOME=${OHOS_SDK_ROOT}"
        "-DOHOS_NDK_HOME=${OHOS_NDK_PATH}"
        "-DCMAKE_SYSTEM_VERSION=${VCPKG_DETECTED_CMAKE_SYSTEM_VERSION}"
        "-DCMAKE_FIND_ROOT_PATH=${OHOS_NDK_PATH}/sysroot"
        "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY"
        "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
        "-DCMAKE_LIBRARY_PATH=${OHOS_NDK_PATH}/sysroot/usr/lib/${OHOS_ARCH_DIR}"
        "-DCMAKE_INCLUDE_PATH=${OHOS_NDK_PATH}/sysroot/usr/include"
    )

elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_PLATFORM_TOOLSET VERSION_LESS "v142")
        message(WARNING "TGFX requires Visual Studio 2019+ for optimal C++17 support")
    endif()

    list(APPEND PLATFORM_OPTIONS
            -DWIN32=TRUE
    )
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_OPTIONS
            -DAPPLE=TRUE
            -DMACOS=TRUE
    )
elseif(VCPKG_TARGET_IS_IOS)
    list(APPEND PLATFORM_OPTIONS
            -DAPPLE=TRUE
            -DIOS=TRUE
    )
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    # EMSCRIPTEN_PTHREADS 默认开启
    list(APPEND PLATFORM_OPTIONS
            -DWEB=TRUE
            -DEMSCRIPTEN_PTHREADS=TRUE
            -DEMSCRIPTEN=TRUE
    )
endif()

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
                COMMAND ${XCODEBUILD_EXECUTABLE} -sdk -version
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
            -DTGFX_USE_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/tgfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
