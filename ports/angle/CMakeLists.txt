cmake_minimum_required(VERSION 3.8)
project(angle CXX C)

if(WIN32 AND NOT WINDOWS_STORE)
    set(WINDOWS_DESKTOP 1)
else()
    set(WINDOWS_DESKTOP 0)
endif()
if (WINDOWS_DESKTOP OR WINDOWS_STORE)
    set(WINDOWS_ANY 1)
else()
    set(WINDOWS_ANY 0)
endif()

if(UNIX AND NOT APPLE)
    set(LINUX 1)
else()
    set(LINUX 0)
endif()

if(WINDOWS_ANY)
    add_compile_options(/d2guard4 /Wv:18 /guard:cf)
else()
    add_compile_options(-std=c++17 -fPIC)
endif()

if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -framework Cocoa -framework OpenGL -framework IOKit -framework CoreFoundation -framework IOSurface -framework QuartzCore -framework CoreGraphics")
endif()
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}")
set(CMAKE_STATIC_LIBRARY_PREFIX "")

add_definitions(
    -D_CRT_SECURE_NO_DEPRECATE
    -D_SCL_SECURE_NO_WARNINGS
    -D_HAS_EXCEPTIONS=0
    -DNOMINMAX
    -DANGLE_STANDALONE_BUILD
    -DANGLE_ENABLE_DEBUG_ANNOTATIONS
)

configure_file(commit.h include/id/commit.h COPYONLY)
include_directories(include src ${CMAKE_CURRENT_BINARY_DIR}/include)

##########
# angle::common
if(WINDOWS_ANY)
    set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_mac|_posix")
elseif(LINUX)
    set(ANGLE_COMMON_PLATFORM_FILTER "_win|_mac")
elseif(APPLE)
    set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_win")
endif()
file(GLOB ANGLE_COMMON_SOURCES 
	"src/common/*.h" 
	"src/common/*.inl" 
	"src/common/*.cpp" 
	"src/common/third_party/base/anglebase/*.h" 
	"src/common/third_party/base/anglebase/*.cc" 
	"src/common/third_party/base/anglebase/containers/*.h" 
	"src/common/third_party/base/anglebase/numerics/*.h" 
	"src/common/third_party/base/anglebase/numerics/*.cc" 
	"src/common/third_party/xxhash/*.h" 
	"src/common/third_party/xxhash/*.c" 
	"src/common/third_party/smhasher/src/*.h" 
	"src/common/third_party/smhasher/src/*.cpp")
list(FILTER ANGLE_COMMON_SOURCES EXCLUDE REGEX "_unittest|event_tracer|${ANGLE_COMMON_PLATFORM_FILTER}")
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
    "src/compiler/translator/tree_ops/*.h"
    "src/compiler/translator/tree_ops/*.cpp"
    "src/compiler/translator/tree_util/*.h"
    "src/compiler/translator/tree_util/*.cpp"
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
if(WINDOWS_DESKTOP OR LINUX OR APPLE)
    if(WINDOWS_DESKTOP)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/wgl/*.cpp"
            "src/libANGLE/renderer/gl/wgl/*.inl"
            "src/libANGLE/renderer/gl/wgl/*.h"
        )
    elseif(APPLE)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/cgl/*.mm"
            "src/libANGLE/renderer/gl/cgl/*.cpp"
            "src/libANGLE/renderer/gl/cgl/*.inl"
            "src/libANGLE/renderer/gl/cgl/*.h"
            "gpu_info_util/SystemInfo_mac.mm"
        )
    elseif(LINUX)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/glx/*.cpp"
            "src/libANGLE/renderer/gl/glx/*.inl"
            "src/libANGLE/renderer/gl/glx/*.h"
        )
    endif()

    file(GLOB LIBANGLE_GL_SOURCES
        "src/libANGLE/renderer/gl/*.cpp"
        "src/libANGLE/renderer/gl/*.inl"
        "src/libANGLE/renderer/gl/*.h"

        ${ANGLE_RENDERER_OPENGL_PLATFORM}
    )
    list(FILTER LIBANGLE_GL_SOURCES EXCLUDE REGEX "_unittest")
    add_library(angle_renderer_opengl INTERFACE)
    target_sources(angle_renderer_opengl INTERFACE ${LIBANGLE_GL_SOURCES})
    target_compile_definitions(angle_renderer_opengl INTERFACE -DANGLE_ENABLE_OPENGL)
    add_library(angle::renderer::opengl ALIAS angle_renderer_opengl)
endif()

# D3D Renderers
if(WINDOWS_ANY)
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
        list(FILTER LIBANGLE_D3D_DESKTOP_SOURCES INCLUDE REGEX "d3d9|win32|converged")
        find_library(D3D9_LIB NAMES d3d9)
        add_library(angle_renderer_win32 INTERFACE)
        target_sources(angle_renderer_win32 INTERFACE ${LIBANGLE_D3D_DESKTOP_SOURCES})
        target_compile_definitions(angle_renderer_win32 INTERFACE -DANGLE_ENABLE_D3D9)
        target_link_libraries(angle_renderer_win32 INTERFACE ${D3D9_LIB})
        add_library(angle::renderer::win32 ALIAS angle_renderer_win32)
    endif()

    ## D3D11 Base renderer
    list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "winrt|d3d9|win32|converged")
    find_library(DXGUID_LIB NAMES dxguid)
    find_library(D3D11_LIB NAMES d3d11)
    add_library(angle_renderer_d3d INTERFACE)
    target_sources(angle_renderer_d3d INTERFACE ${LIBANGLE_D3D_SOURCES})
    target_compile_definitions(angle_renderer_d3d INTERFACE
        -DANGLE_ENABLE_D3D11
        "-DANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }"
    )
    target_link_libraries(angle_renderer_d3d INTERFACE d3d11 dxguid)
    add_library(angle::renderer::d3d ALIAS angle_renderer_d3d)
endif()

## Core libANGLE library
if(WINDOWS_ANY)
    set(LIBANGLE_SOURCES_PLATFORM
        "src/third_party/systeminfo/SystemInfo.cpp"
    )
else()
    set(LIBANGLE_SOURCES_PLATFORM )
endif()

file(GLOB LIBANGLE_SOURCES
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

    ${LIBANGLE_SOURCES_PLATFORM}
)
list(FILTER LIBANGLE_SOURCES EXCLUDE REGEX "_unittest")

if(LINUX OR APPLE)
    set(LIBANGLE_RENDERER_PLATFORM
        angle::renderer::opengl
    )
elseif(WINDOWS_STORE)
    set(LIBANGLE_RENDERER_PLATFORM
        angle::renderer::d3d
        angle::renderer::winrt
    )
elseif(WINDOWS_DESKTOP)
    set(LIBANGLE_RENDERER_PLATFORM
        angle::renderer::d3d
        angle::renderer::win32
        angle::renderer::opengl
        gdi32
    )
else()
    set(LIBANGLE_RENDERER_PLATFORM )
endif()

if(LINUX)
    set(LIBANGLE_RENDERER_COMPILEDEF
        -DANGLE_USE_X11
    )
else()
    set(LIBANGLE_RENDERER_COMPILEDEF )
endif()

add_library(libANGLE STATIC ${LIBANGLE_SOURCES})
target_link_libraries(libANGLE PRIVATE
    angle::common
    angle::image_util
    angle::translator
    angle::preprocessor
    ${LIBANGLE_RENDERER_PLATFORM}
)
target_include_directories(libANGLE PRIVATE "src/third_party/khronos")
target_compile_definitions(libANGLE
    PRIVATE -DANGLE_ENABLE_NULL
    PUBLIC 
        -DLIBANGLE_IMPLEMENTATION 
        ${LIBANGLE_RENDERER_COMPILEDEF}
)
add_library(angle::libANGLE ALIAS libANGLE)

##########
# libGLESv2
file(GLOB LIBGLESV2_SOURCES "src/libGLESv2/*.h" "src/libGLESv2/*.cpp" "src/libGLESv2/libGLESv2_autogen.def")
add_library(libGLESv2 ${LIBGLESV2_SOURCES})
target_link_libraries(libGLESv2 PRIVATE angle::common angle::libANGLE)
target_compile_definitions(libGLESv2
    PRIVATE -DLIBGLESV2_IMPLEMENTATION
    PUBLIC
        -DGL_GLEXT_PROTOTYPES
        -DGL_API=
        -DGL_APICALL=
        -DEGLAPI=
        -DGL_API=
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
target_include_directories(libEGL PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")


SET_TARGET_PROPERTIES(libANGLE PROPERTIES PREFIX "")
SET_TARGET_PROPERTIES(libGLESv2 PROPERTIES PREFIX "")
SET_TARGET_PROPERTIES(libEGL PROPERTIES PREFIX "")

install(TARGETS libEGL libGLESv2 EXPORT ANGLEExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

#install(EXPORT ANGLEExport FILE unofficial-angle-config.cmake NAMESPACE unofficial::angle:: DESTINATION share/unofficial-angle)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY include/
        DESTINATION include
        FILES_MATCHING PATTERN "*.h"
        PATTERN "GLSLANG" EXCLUDE
        PATTERN "EGL" EXCLUDE
        PATTERN "KHR" EXCLUDE
        PATTERN "export.h" EXCLUDE
    )
endif()

