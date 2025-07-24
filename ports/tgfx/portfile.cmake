include("${CMAKE_CURRENT_LIST_DIR}/tgfx-functions.cmake")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/tgfx
    REF 0334e47271024633da29f357dc7e400b0d4761ff
    SHA512 4f3c8ac8dda4a973bc147f4e09e0242ee0d633ee167703153132d02abf529b6a76a4834cf11b50642ea37f0e97d2e47cc41d38b5bcabaeca14521f025d3b71df
    PATCHES
        add-vcpkg-install.patch
)

parse_and_declare_deps_externals("${SOURCE_PATH}")

get_tgfx_externals("${SOURCE_PATH}")

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

execute_process(
    COMMAND "${NODEJS}" --version
    OUTPUT_VARIABLE NODEJS_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NODEJS_VERSION_OUTPUT MATCHES "v([0-9]+)\\.([0-9]+)")
    if(CMAKE_MATCH_1 LESS 14 OR (CMAKE_MATCH_1 EQUAL 14 AND CMAKE_MATCH_2 LESS 14))
        message(FATAL_ERROR "NodeJS version ${NODEJS_VERSION_OUTPUT} is too old. TGFX requires NodeJS 14.14.0+")
    endif()
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(CMAKE_VERSION VERSION_LESS "3.13.0")
    message(FATAL_ERROR "CMake ${CMAKE_VERSION} is too old. TGFX requires CMake 3.13.0+")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        svg             TGFX_BUILD_SVG
        layers          TGFX_BUILD_LAYERS
        drawers         TGFX_BUILD_DRAWERS
        qt              TGFX_USE_QT
        swiftshader     TGFX_USE_SWIFTSHADER
        angle           TGFX_USE_ANGLE
        async-promise   TGFX_USE_ASYNC_PROMISE
    INVERTED_FEATURES
        exclude-opengl          TGFX_USE_OPENGL
        exclude-faster-blur     TGFX_USE_FASTER_BLUR
)

if("qt" IN_LIST FEATURES)
    find_package(QT NAMES Qt6 Qt5 QUIET)
    if(QT_FOUND AND QT_VERSION VERSION_LESS "5.13.0")
        message(FATAL_ERROR "Qt version ${QT_VERSION} is too old. TGFX requires Qt 5.13.0+")
    endif()
endif()

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
    
elseif(VCPKG_TARGET_IS_IOS)
    list(APPEND PLATFORM_OPTIONS
        -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
    )
    
elseif(VCPKG_TARGET_IS_OSX)
    set(osx_deployment_target "10.15")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(osx_deployment_target "11.0")
    endif()
    
    list(APPEND PLATFORM_OPTIONS
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${osx_deployment_target}
    )
    
elseif(VCPKG_TARGET_IS_WINDOWS)
    # Windows configuration
    if(VCPKG_PLATFORM_TOOLSET VERSION_LESS "v142")
        message(WARNING "TGFX requires Visual Studio 2019+ for optimal C++17 support")
    endif()
    
    list(APPEND PLATFORM_OPTIONS
        -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    )
    
    if(VCPKG_TARGET_IS_UWP)
        list(APPEND PLATFORM_OPTIONS 
            -DTGFX_UWP_BUILD=ON
        )
    endif()
    
elseif(VCPKG_TARGET_IS_LINUX)
    list(APPEND PLATFORM_OPTIONS
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    )
endif()

if(VCPKG_DETECTED_CMAKE_C_COMPILER)
    list(APPEND PLATFORM_OPTIONS -DCMAKE_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER})
endif()
if(VCPKG_DETECTED_CMAKE_CXX_COMPILER)
    list(APPEND PLATFORM_OPTIONS -DCMAKE_CXX_COMPILER=${VCPKG_DETECTED_CMAKE_CXX_COMPILER})
endif()

file(READ "${SOURCE_PATH}/CMakeLists.txt" CMAKELIST_CONTENT)

string(REPLACE 
    "target_include_directories(tgfx PUBLIC include PRIVATE src)"
    "target_include_directories(tgfx PUBLIC \$<BUILD_INTERFACE:\${CMAKE_CURRENT_SOURCE_DIR}/include> \$<INSTALL_INTERFACE:include> PRIVATE src)"
    CMAKELIST_CONTENT "${CMAKELIST_CONTENT}")

string(REPLACE 
    "target_include_directories(tgfx-drawers PUBLIC drawers/include PRIVATE include drawers/src)"
    "target_include_directories(tgfx-drawers PUBLIC \$<BUILD_INTERFACE:\${CMAKE_CURRENT_SOURCE_DIR}/drawers/include> \$<INSTALL_INTERFACE:include> PRIVATE include drawers/src)"
    CMAKELIST_CONTENT "${CMAKELIST_CONTENT}")

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${CMAKELIST_CONTENT}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
        -DTGFX_BUILD_TESTS=OFF
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
    OPTIONS_DEBUG
        -DTGFX_BUILD_TESTS=OFF
    OPTIONS_RELEASE
        -DTGFX_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME tgfx CONFIG_PATH share/tgfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
