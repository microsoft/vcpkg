include("${CMAKE_CURRENT_LIST_DIR}/tgfx-functions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ohos-ndk-finder.cmake")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Tencent/tgfx
        REF b53f462a34c766cb2c2947391d218f5e3be32038
        SHA512 3b23422a0e454155e0e164156a20eeb65f526498344de45dd48467aa45529443a506375632acdedde2ea0399b3bb3a5b63e76903af6723db8b3dff873a8d41bc
)
#set(SOURCE_PATH "/Users/huangbeiao/Documents/UGit/tgfx-vcpkg")

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

set(PLATFORM_OPTIONS)

if(VCPKG_TARGET_IS_ANDROID)
    if(NOT VCPKG_DETECTED_CMAKE_ANDROID_NDK)
        message(FATAL_ERROR "Android NDK not detected. Please set ANDROID_NDK_HOME")
    endif()

    list(APPEND PLATFORM_OPTIONS
            -DCMAKE_ANDROID_NDK=${VCPKG_DETECTED_CMAKE_ANDROID_NDK}
    )
elseif(VCPKG_CMAKE_SYSTEM_NAME MATCHES "OHOS")

    # NDK_PATH = /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native
    set(NDK_PATH "")
    set(NDK_VERSION "")
    find_ohos_ndk(NDK_PATH NDK_VERSION)

    set(ENV{CMAKE_OHOS_NDK} "${NDK_PATH}")
    message(STATUS "Using OHOS NDK: ${NDK_PATH}")

    list(APPEND PLATFORM_OPTIONS
        "-DCMAKE_OHOS_NDK=${NDK_PATH}"
    )

elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_PLATFORM_TOOLSET VERSION_LESS "v142")
        message(WARNING "TGFX requires Visual Studio 2019+ for optimal C++17 support")
    endif()
endif()

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
            ${PLATFORM_OPTIONS}
            -DTGFX_USE_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/tgfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
