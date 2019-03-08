cmake_minimum_required(VERSION 3.8)
project(angle CXX)

if(WIN32 AND NOT WINDOWS_STORE)
    set(WINDOWS_DESKTOP 1)
else()
    set(WINDOWS_DESKTOP 0)
endif()

add_compile_options(/d2guard4 /Wv:18)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /guard:cf")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /guard:cf")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /guard:cf")

add_definitions(
    -D_CRT_SECURE_NO_DEPRECATE
    -D_SCL_SECURE_NO_WARNINGS
    -D_HAS_EXCEPTIONS=0
    -DNOMINMAX
    -DANGLE_STANDALONE_BUILD
    -DANGLE_ENABLE_DEBUG_ANNOTATIONS
)

configure_file(src/commit.h include/id/commit.h COPYONLY)
include_directories(include src ${CMAKE_CURRENT_BINARY_DIR}/include)

##########
# angle::common
file(GLOB ANGLE_COMMON_SOURCES 
    "src/common/*.h" 
    "src/common/*.inl" 
    "src/common/*.cpp" 
    "src/common/third_party/base/*.h"
    "src/common/third_party/base/anglebase/*.cc"
    "src/common/third_party/base/anglebase/*.h"
    "src/common/third_party/smhasher/src/*.h"
    "src/common/third_party/smhasher/src/*.cpp")
list(FILTER ANGLE_COMMON_SOURCES EXCLUDE REGEX "_unittest|event_tracer|_linux|_mac")
add_library(angle_common STATIC ${ANGLE_COMMON_SOURCES})
target_include_directories(angle_common PUBLIC src/common/third_party/base)
add_library(angle::common ALIAS angle_common)

##########
# angle::image_util
file(GLOB ANGLE_IMAGE_UTIL_SOURCES "src/image_util/*.h" "src/image_util/*.inl" "src/image_util/*.cpp")
add_library(angle_image_util STATIC ${ANGLE_IMAGE_UTIL_SOURCES})
target_link_libraries(angle_image_util PRIVATE angle::common)
add_library(angle::image_util ALIAS angle_image_util)

##########
# angle::translator
file(GLOB TRANSLATOR_SOURCES
    "src/compiler/translator/glslang.l"
    "src/compiler/translator/glslang.y"
    "src/compiler/translator/*.h"
    "src/compiler/translator/*.cpp"
    "src/third_party/compiler/ArrayBoundsClamper.cpp"
)
add_library(angle_translator STATIC ${TRANSLATOR_SOURCES})
target_compile_definitions(angle_translator PUBLIC
    -DANGLE_ENABLE_ESSL
    -DANGLE_ENABLE_GLSL
    -DANGLE_ENABLE_HLSL
)
target_link_libraries(angle_translator PRIVATE angle::common)
add_library(angle::translator ALIAS angle_translator)

##########
# angle::preprocessor
file(GLOB PREPROCESSOR_SOURCES
    "src/compiler/preprocessor/*.h"
    "src/compiler/preprocessor/*.cpp"
)
add_library(angle_preprocessor STATIC ${PREPROCESSOR_SOURCES})
target_link_libraries(angle_preprocessor PRIVATE angle::common)
add_library(angle::preprocessor ALIAS angle_preprocessor)

##########
# libANGLE

## OpenGL Renderer
if(WINDOWS_DESKTOP)
    file(GLOB LIBANGLE_GL_SOURCES
        "src/libANGLE/renderer/gl/*.cpp"
        "src/libANGLE/renderer/gl/*.inl"
        "src/libANGLE/renderer/gl/*.h"

        "src/libANGLE/renderer/gl/wgl/*.cpp"
        "src/libANGLE/renderer/gl/wgl/*.inl"
        "src/libANGLE/renderer/gl/wgl/*.h"
    )
    list(FILTER LIBANGLE_GL_SOURCES EXCLUDE REGEX "_unittest")
    add_library(angle_renderer_opengl INTERFACE)
    target_sources(angle_renderer_opengl INTERFACE ${LIBANGLE_GL_SOURCES})
    target_compile_definitions(angle_renderer_opengl INTERFACE -DANGLE_ENABLE_OPENGL)
    add_library(angle::renderer::opengl ALIAS angle_renderer_opengl)
endif()

## All D3D Sources
file(GLOB_RECURSE LIBANGLE_D3D_SOURCES
    "src/libANGLE/renderer/d3d/*.cpp"
    "src/libANGLE/renderer/d3d/*.inl"
    "src/libANGLE/renderer/d3d/*.h"
)
list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "_unittest")

## WinRT D3D Renderer
if(WINDOWS_STORE)
    set(LIBANGLE_D3D_WINRT_SOURCES ${LIBANGLE_D3D_SOURCES})
    list(FILTER LIBANGLE_D3D_WINRT_SOURCES INCLUDE REGEX "winrt")
    add_library(angle_renderer_winrt INTERFACE)
    target_sources(angle_renderer_winrt INTERFACE ${LIBANGLE_D3D_WINRT_SOURCES})
    add_library(angle::renderer::winrt ALIAS angle_renderer_winrt)
endif()

## Win32/d3d9 D3D Renderer
if(WINDOWS_DESKTOP)
    set(LIBANGLE_D3D_DESKTOP_SOURCES ${LIBANGLE_D3D_SOURCES})
    list(FILTER LIBANGLE_D3D_DESKTOP_SOURCES INCLUDE REGEX "d3d9|win32")
    find_library(D3D9_LIB NAMES d3d9)
    add_library(angle_renderer_win32 INTERFACE)
    target_sources(angle_renderer_win32 INTERFACE ${LIBANGLE_D3D_DESKTOP_SOURCES})
    target_compile_definitions(angle_renderer_win32 INTERFACE -DANGLE_ENABLE_D3D9)
    target_link_libraries(angle_renderer_win32 INTERFACE ${D3D9_LIB})
    add_library(angle::renderer::win32 ALIAS angle_renderer_win32)
endif()

## D3D11 Base renderer
list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "winrt|d3d9|win32")
find_library(DXGUID_LIB NAMES dxguid)
find_library(D3D11_LIB NAMES d3d11)
add_library(angle_renderer_d3d INTERFACE)
target_sources(angle_renderer_d3d INTERFACE ${LIBANGLE_D3D_SOURCES})
target_compile_definitions(angle_renderer_d3d INTERFACE
    -DANGLE_ENABLE_D3D11
    "-DANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }"
)
target_link_libraries(angle_renderer_d3d INTERFACE ${D3D11_LIB} ${DXGUID_LIB})
add_library(angle::renderer::d3d ALIAS angle_renderer_d3d)

## Core libANGLE library
file(GLOB LIBANGLE_SOURCES
    "src/third_party/systeminfo/SystemInfo.cpp"
    "src/common/third_party/murmurhash/MurmurHash3.cpp"
    "src/common/event_tracer.cpp"

    "src/libANGLE/*.cpp"
    "src/libANGLE/*.inl"
    "src/libANGLE/*.h"

    "src/libANGLE/renderer/*.cpp"
    "src/libANGLE/renderer/*.inl"
    "src/libANGLE/renderer/*.h"

    "src/libANGLE/renderer/null/*.cpp"
    "src/libANGLE/renderer/null/*.inl"
    "src/libANGLE/renderer/null/*.h"
)
list(FILTER LIBANGLE_SOURCES EXCLUDE REGEX "_unittest")

add_library(libANGLE STATIC ${LIBANGLE_SOURCES})
target_link_libraries(libANGLE PRIVATE
    angle::common
    angle::image_util
    angle::translator
    angle::preprocessor
    angle::renderer::d3d
    $<$<BOOL:${WINDOWS_STORE}>:angle::renderer::winrt>
    $<$<BOOL:${WINDOWS_DESKTOP}>:angle::renderer::win32>
    $<$<BOOL:${WINDOWS_DESKTOP}>:angle::renderer::opengl>
    $<$<BOOL:${WINDOWS_DESKTOP}>:gdi32>
)
target_include_directories(libANGLE PRIVATE "src/third_party/khronos")
target_compile_definitions(libANGLE
    PRIVATE -DANGLE_ENABLE_NULL
    PUBLIC -DLIBANGLE_IMPLEMENTATION
)
add_library(angle::libANGLE ALIAS libANGLE)

##########
# libGLESv2
file(GLOB LIBGLESV2_SOURCES "src/libGLESv2/*.h" "src/libGLESv2/*.cpp" "src/libGLESv2/libGLESv2.def")
add_library(libGLESv2 ${LIBGLESV2_SOURCES})
target_link_libraries(libGLESv2 PRIVATE angle::common angle::libANGLE)
target_compile_definitions(libGLESv2
    PRIVATE -DLIBGLESV2_IMPLEMENTATION
    PUBLIC
        -DGL_GLEXT_PROTOTYPES
        -DGL_APICALL=
        -DEGLAPI=
)
target_include_directories(libGLESv2 PUBLIC "$<INSTALL_INTERFACE:include>")

##########
# libEGL
add_library(libEGL
    "src/libEGL/libEGL.def"
    "src/libEGL/libEGL.cpp"
    "src/libEGL/libEGL.rc"
    "src/libEGL/resource.h"
)
target_link_libraries(libEGL PRIVATE angle::common angle::libANGLE libGLESv2)
target_include_directories(libEGL PUBLIC "$<INSTALL_INTERFACE:include>")

install(TARGETS libEGL libGLESv2 EXPORT ANGLEExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT ANGLEExport FILE ms-angle-config.cmake NAMESPACE ms-angle:: DESTINATION share/ms-angle)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY include/
        DESTINATION include
        FILES_MATCHING PATTERN "*.h"
        PATTERN "GLSLANG" EXCLUDE
        PATTERN "export.h" EXCLUDE
    )
endif()
