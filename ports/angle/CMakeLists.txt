cmake_minimum_required(VERSION 3.8)
project(angle CXX C)

if(WIN32 AND NOT WINDOWS_STORE)
    set(WINDOWS_DESKTOP 1)
else()
    set(WINDOWS_DESKTOP 0)
endif()

if(UNIX AND NOT APPLE)
    set(LINUX 1)
else()
    set(LINUX 0)
endif()

if(MSVC)
    add_compile_options(/d2guard4 /Wv:18 /guard:cf /permissive /bigobj)
else()
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -framework Cocoa -framework OpenGL -framework IOKit -framework CoreFoundation -framework IOSurface -framework QuartzCore -framework CoreGraphics")
endif()
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}")
set(CMAKE_STATIC_LIBRARY_PREFIX "")

if (WINDOWS_STORE)
    set(WINRT_DEFINES -DANGLE_ENABLE_WINDOWS_UWP -DWINAPI_FAMILY=WINAPI_FAMILY_PC_APP)
else()
    set(WINRT_DEFINES)
endif()
add_definitions(
    -D_CRT_SECURE_NO_DEPRECATE
    -D_SCL_SECURE_NO_WARNINGS
    -DGL_SILENCE_DEPRECATION
    -D_HAS_EXCEPTIONS=0
    -DNOMINMAX
    -DANGLE_STANDALONE_BUILD
    ${WINRT_DEFINES}
)
add_compile_options("$<$<CONFIG:DEBUG>:-DANGLE_ENABLE_DEBUG_ANNOTATIONS>")
if(WIN32)
    add_definitions(-DANGLE_IS_WIN)
endif()
if(LINUX)
    add_definitions(-DANGLE_IS_LINUX)
endif()
if(ANGLE_IS_64_BIT_CPU)
    add_definitions(-DANGLE_IS_64_BIT_CPU)
elseif(ANGLE_IS_32_BIT_CPU)
    add_definitions(-DANGLE_IS_32_BIT_CPU)
endif()

configure_file(angle_commit.h include/id/commit.h COPYONLY)
#include_directories(include src ${CMAKE_CURRENT_BINARY_DIR}/include)
include_directories("$<INSTALL_INTERFACE:include>" "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>" "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>" "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>")
##########
# angle::common
if(WINDOWS_DESKTOP)
    set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_apple|_mac|_ios|_posix|_winuwp")
elseif(WINDOWS_STORE)
    set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_apple|_mac|_ios|_posix|_win32")
elseif(LINUX)
    set(ANGLE_COMMON_PLATFORM_FILTER "_win|_apple|_mac|_ios")
elseif(APPLE)
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin") # macOS
        set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_win|_ios")
    else() # other Apple platforms (iOS, etc)
        set(ANGLE_COMMON_PLATFORM_FILTER "_linux|_win|_mac")
    endif()
endif()
file(GLOB ANGLE_COMMON_SOURCES 
    "src/common/*.h"
    "src/common/*.inc"
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
add_library(angle_common OBJECT ${ANGLE_COMMON_SOURCES})
target_include_directories(angle_common PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/common/third_party/base>")
add_library(angle::common ALIAS angle_common)

##########
# angle::compression
file(GLOB ANGLE_COMPRESSION_UTILS_SOURCES "third_party/zlib/google/compression_utils_portable.*")
find_package(ZLIB REQUIRED)
add_library(angle_compression_utils OBJECT ${ANGLE_COMPRESSION_UTILS_SOURCES})
target_link_libraries(angle_compression_utils PUBLIC ZLIB::ZLIB)
target_compile_definitions(angle_compression_utils PRIVATE
    -DUSE_SYSTEM_ZLIB
)
target_include_directories(angle_compression_utils INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/third_party/zlib/google>")
add_library(angle::compression ALIAS angle_compression_utils)

##########
# angle::image_util
file(GLOB ANGLE_IMAGE_UTIL_SOURCES "src/image_util/*.h" "src/image_util/*.inc" "src/image_util/*.cpp")
add_library(angle_image_util OBJECT ${ANGLE_IMAGE_UTIL_SOURCES})
target_link_libraries(angle_image_util PRIVATE angle::common)
add_library(angle::image_util ALIAS angle_image_util)

##########
# angle::translator
file(GLOB TRANSLATOR_SOURCES
    "src/compiler/translator/BaseTypes.h"
    "src/compiler/translator/BuiltInFunctionEmulator.cpp"
    "src/compiler/translator/BuiltInFunctionEmulator.h"
    "src/compiler/translator/CallDAG.cpp"
    "src/compiler/translator/CallDAG.h"
    "src/compiler/translator/CodeGen.cpp"
    "src/compiler/translator/CollectVariables.cpp"
    "src/compiler/translator/CollectVariables.h"
    "src/compiler/translator/Common.h"
    "src/compiler/translator/Compiler.cpp"
    "src/compiler/translator/Compiler.h"
    "src/compiler/translator/ConstantUnion.cpp"
    "src/compiler/translator/ConstantUnion.h"
    "src/compiler/translator/Declarator.cpp"
    "src/compiler/translator/Declarator.h"
    "src/compiler/translator/Diagnostics.cpp"
    "src/compiler/translator/Diagnostics.h"
    "src/compiler/translator/DirectiveHandler.cpp"
    "src/compiler/translator/DirectiveHandler.h"
    "src/compiler/translator/ExtensionBehavior.cpp"
    "src/compiler/translator/ExtensionBehavior.h"
    "src/compiler/translator/FlagStd140Structs.cpp"
    "src/compiler/translator/FlagStd140Structs.h"
    "src/compiler/translator/FunctionLookup.cpp"
    "src/compiler/translator/FunctionLookup.h"
    "src/compiler/translator/HashNames.cpp"
    "src/compiler/translator/HashNames.h"
    "src/compiler/translator/ImmutableString.h"
    "src/compiler/translator/ImmutableStringBuilder.cpp"
    "src/compiler/translator/ImmutableStringBuilder.h"
    "src/compiler/translator/InfoSink.cpp"
    "src/compiler/translator/InfoSink.h"
    "src/compiler/translator/Initialize.cpp"
    "src/compiler/translator/Initialize.h"
    "src/compiler/translator/InitializeDll.cpp"
    "src/compiler/translator/InitializeDll.h"
    "src/compiler/translator/InitializeGlobals.h"
    "src/compiler/translator/IntermNode.cpp"
    "src/compiler/translator/IntermNode.h"
    "src/compiler/translator/IsASTDepthBelowLimit.cpp"
    "src/compiler/translator/IsASTDepthBelowLimit.h"
    "src/compiler/translator/Operator.cpp"
    "src/compiler/translator/Operator.h"
    "src/compiler/translator/OutputTree.cpp"
    "src/compiler/translator/OutputTree.h"
    "src/compiler/translator/ParseContext.cpp"
    "src/compiler/translator/ParseContext.h"
    "src/compiler/translator/ParseContext_ESSL_autogen.h"
    "src/compiler/translator/ParseContext_complete_autogen.h"
    "src/compiler/translator/ParseContext_interm.h"
    "src/compiler/translator/PoolAlloc.cpp"
    "src/compiler/translator/PoolAlloc.h"
    "src/compiler/translator/Pragma.h"
    "src/compiler/translator/QualifierTypes.cpp"
    "src/compiler/translator/QualifierTypes.h"
    "src/compiler/translator/Severity.h"
    "src/compiler/translator/ShaderLang.cpp"
    "src/compiler/translator/ShaderVars.cpp"
    "src/compiler/translator/StaticType.h"
    "src/compiler/translator/Symbol.cpp"
    "src/compiler/translator/Symbol.h"
    "src/compiler/translator/SymbolTable.cpp"
    "src/compiler/translator/SymbolTable.h"
    "src/compiler/translator/SymbolTable_autogen.h"
    "src/compiler/translator/SymbolUniqueId.cpp"
    "src/compiler/translator/SymbolUniqueId.h"
    "src/compiler/translator/TranslatorESSL.h"
    "src/compiler/translator/TranslatorGLSL.h"
    "src/compiler/translator/TranslatorHLSL.h"
    "src/compiler/translator/TranslatorMetal.h"
    "src/compiler/translator/TranslatorVulkan.h"
    "src/compiler/translator/Types.cpp"
    "src/compiler/translator/Types.h"
    "src/compiler/translator/ValidateAST.cpp"
    "src/compiler/translator/ValidateAST.h"
    "src/compiler/translator/ValidateBarrierFunctionCall.cpp"
    "src/compiler/translator/ValidateBarrierFunctionCall.h"
    "src/compiler/translator/ValidateClipCullDistance.cpp"
    "src/compiler/translator/ValidateClipCullDistance.h"
    "src/compiler/translator/ValidateGlobalInitializer.cpp"
    "src/compiler/translator/ValidateGlobalInitializer.h"
    "src/compiler/translator/ValidateLimitations.cpp"
    "src/compiler/translator/ValidateLimitations.h"
    "src/compiler/translator/ValidateMaxParameters.cpp"
    "src/compiler/translator/ValidateMaxParameters.h"
    "src/compiler/translator/ValidateOutputs.cpp"
    "src/compiler/translator/ValidateOutputs.h"
    "src/compiler/translator/ValidateSwitch.cpp"
    "src/compiler/translator/ValidateSwitch.h"
    "src/compiler/translator/ValidateVaryingLocations.cpp"
    "src/compiler/translator/ValidateVaryingLocations.h"
    "src/compiler/translator/VariablePacker.cpp"
    "src/compiler/translator/VariablePacker.h"
    "src/compiler/translator/blocklayout.cpp"
    "src/compiler/translator/glslang.h"
    "src/compiler/translator/glslang_lex_autogen.cpp"
    "src/compiler/translator/glslang_tab_autogen.cpp"
    "src/compiler/translator/glslang_tab_autogen.h"
    "src/compiler/translator/glslang_wrapper.h"
    "src/compiler/translator/length_limits.h"
    "src/compiler/translator/tree_ops/*.cpp"
    "src/compiler/translator/tree_ops/*.h"
    "src/compiler/translator/tree_ops/gl/ClampFragDepth.h"
    "src/compiler/translator/tree_ops/gl/RegenerateStructNames.h"
    "src/compiler/translator/tree_ops/gl/RewriteRepeatedAssignToSwizzled.h"
    "src/compiler/translator/tree_ops/gl/UseInterfaceBlockFields.h"
    "src/compiler/translator/tree_ops/gl/VectorizeVectorScalarArithmetic.h"
    "src/compiler/translator/tree_ops/gl/mac/AddAndTrueToLoopCondition.h"
    "src/compiler/translator/tree_ops/gl/mac/RewriteDoWhile.h"
    "src/compiler/translator/tree_ops/gl/mac/UnfoldShortCircuitAST.h"
    "src/compiler/translator/tree_ops/vulkan/EarlyFragmentTestsOptimization.h"
    "src/compiler/translator/tree_util/*.h"
    "src/compiler/translator/tree_util/*.cpp"
    "src/compiler/translator/util.cpp"
    "src/compiler/translator/util.h"
    "src/third_party/compiler/ArrayBoundsClamper.cpp"
    "src/third_party/compiler/ArrayBoundsClamper.h"
)
list(FILTER TRANSLATOR_SOURCES EXCLUDE REGEX "_unittest")
file(GLOB TRANSLATOR_GLSL_BASE_SOURCES
    "src/compiler/translator/OutputGLSLBase.cpp"
    "src/compiler/translator/OutputGLSLBase.h"
)
file(GLOB TRANSLATOR_GLSL_AND_VULKAN_BASE_SOURCES 
    "src/compiler/translator/BuiltinsWorkaroundGLSL.cpp"
    "src/compiler/translator/BuiltinsWorkaroundGLSL.h"
    "src/compiler/translator/OutputGLSL.cpp"
    "src/compiler/translator/OutputGLSL.h"
)
file(GLOB TRANSLATOR_ESSL_SOURCES 
    "src/compiler/translator/OutputESSL.cpp"
    "src/compiler/translator/OutputESSL.h"
    "src/compiler/translator/TranslatorESSL.cpp"
    "src/compiler/translator/tree_ops/gl/RecordConstantPrecision.cpp"
    "src/compiler/translator/tree_ops/gl/RecordConstantPrecision.h"
)
file(GLOB TRANSLATOR_GLSL_SOURCES
    "src/compiler/translator/BuiltInFunctionEmulatorGLSL.cpp"
    "src/compiler/translator/BuiltInFunctionEmulatorGLSL.h"
    "src/compiler/translator/ExtensionGLSL.cpp"
    "src/compiler/translator/ExtensionGLSL.h"
    "src/compiler/translator/TranslatorGLSL.cpp"
    "src/compiler/translator/VersionGLSL.cpp"
    "src/compiler/translator/VersionGLSL.h"
    "src/compiler/translator/tree_ops/gl/ClampFragDepth.cpp"
    "src/compiler/translator/tree_ops/gl/RegenerateStructNames.cpp"
    "src/compiler/translator/tree_ops/gl/RewriteRepeatedAssignToSwizzled.cpp"
    "src/compiler/translator/tree_ops/gl/UseInterfaceBlockFields.cpp"
    "src/compiler/translator/tree_ops/gl/VectorizeVectorScalarArithmetic.cpp"
    "src/compiler/translator/tree_ops/gl/mac/RewriteRowMajorMatrices.h"
    "src/compiler/translator/tree_ops/gl/mac/RewriteUnaryMinusOperatorFloat.h"
)
file(GLOB TRANSLATOR_GLSL_MAC_SOURCES
    "src/compiler/translator/tree_ops/gl/mac/AddAndTrueToLoopCondition.cpp"
    "src/compiler/translator/tree_ops/gl/mac/RewriteDoWhile.cpp"
    "src/compiler/translator/tree_ops/gl/mac/RewriteRowMajorMatrices.cpp"
    "src/compiler/translator/tree_ops/gl/mac/RewriteUnaryMinusOperatorFloat.cpp"
    "src/compiler/translator/tree_ops/gl/mac/UnfoldShortCircuitAST.cpp"
)
file(GLOB TRANSLATOR_HLSL_SOURCES
    "src/compiler/translator/*HLSL.h"
    "src/compiler/translator/*HLSL.cpp"
    "src/compiler/translator/emulated_builtin_functions_hlsl_autogen.cpp"
    "src/compiler/translator/tree_ops/d3d/*.cpp"
    "src/compiler/translator/tree_ops/d3d/*.h"
)
if(ANDROID)
    list(APPEND TRANSLATOR_SOURCES "src/compiler/translator/ImmutableString_ESSL_autogen.cpp" "src/compiler/translator/SymbolTable_ESSL_autogen.cpp")
else()
    list(APPEND TRANSLATOR_SOURCES "src/compiler/translator/ImmutableString_autogen.cpp" "src/compiler/translator/SymbolTable_autogen.cpp")
endif()
set(ANGLE_ENABLE_ESSL TRUE)
set(ANGLE_ENABLE_GLSL TRUE)
set(ANGLE_ENABLE_HLSL TRUE)
set(_needs_glsl_base FALSE)
set(_needs_glsl_and_vulkan_base FALSE)
add_library(angle_translator OBJECT ${TRANSLATOR_SOURCES})
if(ANGLE_ENABLE_ESSL)
    set(_needs_glsl_base TRUE)
    target_sources(angle_translator PRIVATE ${TRANSLATOR_ESSL_SOURCES})
    target_compile_definitions(angle_translator PUBLIC -DANGLE_ENABLE_ESSL)
endif()
if(ANGLE_ENABLE_GLSL)
    set(_needs_glsl_base TRUE)
    set(_needs_glsl_and_vulkan_base TRUE)
    target_sources(angle_translator PRIVATE ${TRANSLATOR_GLSL_SOURCES})
    if(APPLE)
        target_sources(angle_translator PRIVATE ${TRANSLATOR_GLSL_MAC_SOURCES})
    endif()
    target_compile_definitions(angle_translator PUBLIC -DANGLE_ENABLE_GLSL)
endif()
if(ANGLE_ENABLE_HLSL)
    target_sources(angle_translator PRIVATE ${TRANSLATOR_HLSL_SOURCES})
    target_compile_definitions(angle_translator PUBLIC -DANGLE_ENABLE_HLSL)
endif()
if(_needs_glsl_base)
    target_sources(angle_translator PRIVATE ${TRANSLATOR_GLSL_BASE_SOURCES})
endif()
if(_needs_glsl_and_vulkan_base)
    target_sources(angle_translator PRIVATE ${TRANSLATOR_GLSL_AND_VULKAN_BASE_SOURCES})
endif()
target_link_libraries(angle_translator PRIVATE angle::common)
add_library(angle::translator ALIAS angle_translator)

##########
# angle::preprocessor
file(GLOB PREPROCESSOR_SOURCES
    "src/compiler/preprocessor/*.h"
    "src/compiler/preprocessor/*.cpp"
)
add_library(angle_preprocessor OBJECT ${PREPROCESSOR_SOURCES})
target_link_libraries(angle_preprocessor PRIVATE angle::common)
add_library(angle::preprocessor ALIAS angle_preprocessor)

##########
# libANGLE

## OpenGL Renderer
if(WINDOWS_DESKTOP OR LINUX OR APPLE)
    if(WINDOWS_DESKTOP)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/wgl/*.cpp"
            "src/libANGLE/renderer/gl/wgl/*.h"
        )
    elseif(APPLE)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/cgl/*.mm"
            "src/libANGLE/renderer/gl/cgl/*.cpp"
            "src/libANGLE/renderer/gl/cgl/*.h"
            "gpu_info_util/SystemInfo_macos.mm"
        )
    elseif(LINUX)
        set(ANGLE_RENDERER_OPENGL_PLATFORM 
            "src/libANGLE/renderer/gl/glx/*.cpp"
            "src/libANGLE/renderer/gl/glx/*.h"
            "src/libANGLE/renderer/gl/egl/*.cpp"
            "src/libANGLE/renderer/gl/egl/*.h"
        )
    endif()

    file(GLOB LIBANGLE_GL_SOURCES
        "src/libANGLE/renderer/gl/*.cpp"
        "src/libANGLE/renderer/gl/*.inc"
        "src/libANGLE/renderer/gl/*.h"

        ${ANGLE_RENDERER_OPENGL_PLATFORM}
    )
    list(FILTER LIBANGLE_GL_SOURCES EXCLUDE REGEX "_unittest")
    add_library(angle_renderer_opengl INTERFACE)
    target_sources(angle_renderer_opengl INTERFACE "$<BUILD_INTERFACE:${LIBANGLE_GL_SOURCES}>")
    target_compile_definitions(angle_renderer_opengl INTERFACE -DANGLE_ENABLE_OPENGL)
    add_library(angle::renderer::opengl ALIAS angle_renderer_opengl)
endif()

# D3D Renderers
if(WIN32)
    ## All D3D Sources
    file(GLOB_RECURSE LIBANGLE_D3D_SOURCES
        "src/libANGLE/renderer/d3d/*.cpp"
        "src/libANGLE/renderer/d3d/*.inc"
        "src/libANGLE/renderer/d3d/*.h"
    )
    list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "_unittest")

    ## WinRT D3D Renderer
    if(WINDOWS_STORE)
        set(LIBANGLE_D3D_WINRT_SOURCES ${LIBANGLE_D3D_SOURCES})
        list(FILTER LIBANGLE_D3D_WINRT_SOURCES INCLUDE REGEX "winrt")
        add_library(angle_renderer_winrt INTERFACE)
        target_sources(angle_renderer_winrt INTERFACE "$<BUILD_INTERFACE:${LIBANGLE_D3D_WINRT_SOURCES}>")
        add_library(angle::renderer::winrt ALIAS angle_renderer_winrt)
    endif()

    ## Win32/d3d9 D3D Renderer
    if(WINDOWS_DESKTOP)
        set(LIBANGLE_D3D_DESKTOP_SOURCES ${LIBANGLE_D3D_SOURCES})
        list(FILTER LIBANGLE_D3D_DESKTOP_SOURCES INCLUDE REGEX "d3d9|win32")
        find_library(D3D9_LIB NAMES d3d9)
        add_library(angle_renderer_win32 INTERFACE)
        target_sources(angle_renderer_win32 INTERFACE "$<BUILD_INTERFACE:${LIBANGLE_D3D_DESKTOP_SOURCES}>")
        target_compile_definitions(angle_renderer_win32 INTERFACE -DANGLE_ENABLE_D3D9)
        target_link_libraries(angle_renderer_win32 INTERFACE d3d9)
        add_library(angle::renderer::win32 ALIAS angle_renderer_win32)
    endif()

    ## D3D11 Base renderer
    list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "winrt|d3d9|win32")
    find_library(DXGUID_LIB NAMES dxguid)
    find_library(D3D11_LIB NAMES d3d11)
    add_library(angle_renderer_d3d INTERFACE)
    target_sources(angle_renderer_d3d INTERFACE "$<BUILD_INTERFACE:${LIBANGLE_D3D_SOURCES}>")
    target_compile_definitions(angle_renderer_d3d INTERFACE
        -DANGLE_ENABLE_D3D11
        "-DANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }"
        -DANGLE_ENABLE_D3D11_COMPOSITOR_NATIVE_WINDOW
    )
    target_link_libraries(angle_renderer_d3d INTERFACE d3d11 dxguid)
    add_library(angle::renderer::d3d ALIAS angle_renderer_d3d)
endif()

## angle::gpu_info_util
file(GLOB ANGLE_GPU_INFO_UTIL_SOURCES
    "src/gpu_info_util/SystemInfo.h"
    "src/gpu_info_util/SystemInfo_internal.h"
    "src/gpu_info_util/SystemInfo.cpp"
)
add_library(angle_gpu_info_util OBJECT ${ANGLE_GPU_INFO_UTIL_SOURCES})
if(WIN32)
    target_sources(angle_gpu_info_util PRIVATE "src/gpu_info_util/SystemInfo_win.cpp")
    target_link_libraries(angle_gpu_info_util PRIVATE setupapi.lib dxgi.lib)
elseif(APPLE)
    target_sources(angle_gpu_info_util PRIVATE "src/gpu_info_util/SystemInfo_apple.mm")
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin") # macOS
        target_sources(angle_gpu_info_util PRIVATE "src/gpu_info_util/SystemInfo_macos.mm")
    endif()
	find_library(IOKit IOKit)
	find_library(CoreFoundation CoreFoundation)
	find_library(CoreGraphics CoreGraphics)
	target_link_libraries(angle_gpu_info_util PRIVATE ${IOKit} ${CoreFoundation} ${CoreGraphics})
elseif(LINUX)
    target_sources(angle_gpu_info_util PRIVATE "src/gpu_info_util/SystemInfo_linux.cpp" "src/gpu_info_util/SystemInfo_x11.cpp")
    target_compile_definitions(angle_gpu_info_util PRIVATE GPU_INFO_USE_X11)
    target_link_libraries(angle_gpu_info_util PRIVATE X11 Xi Xext)
elseif(ANDROID)
    target_sources(angle_gpu_info_util PRIVATE "src/gpu_info_util/SystemInfo_android.cpp")
endif()
target_link_libraries(angle_gpu_info_util PRIVATE angle::common)
add_library(angle::gpu_info_util ALIAS angle_gpu_info_util)

## Core libANGLE library
if(WIN32)
    if(NOT WINDOWS_STORE)
        set(LIBANGLE_SOURCES_PLATFORM
            "src/third_party/systeminfo/SystemInfo.cpp"
        )
    endif()
elseif(APPLE)
    file(GLOB LIBANGLE_SOURCES_PLATFORM
         "src/libANGLE/renderer/*.mm"
    )
else()
    set(LIBANGLE_SOURCES_PLATFORM)
endif()

file(GLOB LIBANGLE_SOURCES
    "src/common/third_party/murmurhash/MurmurHash3.cpp"
    "src/common/event_tracer.cpp"

    "src/libANGLE/*.cpp"
    "src/libANGLE/*.inc"
    "src/libANGLE/*.h"

    "src/libANGLE/renderer/*.cpp"
    "src/libANGLE/renderer/*.h"

    "src/libANGLE/renderer/null/*.cpp"
    "src/libANGLE/renderer/null/*.h"

    # The frame capture headers are always visible to libANGLE.
    "src/libANGLE/capture/*.h"

    # angle_frame_capture_disabled
    "src/libANGLE/capture/FrameCapture_mock.cpp"
    "src/libANGLE/capture/frame_capture_utils_mock.cpp"

    # angle_gl_enum_utils
    "src/libANGLE/capture/gl_enum_utils.cpp"
    "src/libANGLE/capture/gl_enum_utils_autogen.cpp"

    ${LIBANGLE_SOURCES_PLATFORM}
)
list(FILTER LIBANGLE_SOURCES EXCLUDE REGEX "_unittest|glslang_wrapper|dxgi_|d3d_format")
if(WIN32)
    set(LIBANGLE_D3D_FORMAT_TABLES_SOURCES_PLATFORM)
    if(NOT WINDOWS_STORE)
        list(APPEND LIBANGLE_D3D_FORMAT_TABLES_SOURCES_PLATFORM
            "src/libANGLE/renderer/d3d_format.cpp"
            "src/libANGLE/renderer/d3d_format.h"
        )
    endif()
    file(GLOB LIBANGLE_D3D_FORMAT_TABLES_SOURCES
        "src/libANGLE/renderer/dxgi_format_map.h"
        "src/libANGLE/renderer/dxgi_format_map_autogen.cpp"
        "src/libANGLE/renderer/dxgi_support_table.h"
        "src/libANGLE/renderer/dxgi_support_table_autogen.cpp"

        ${LIBANGLE_D3D_FORMAT_TABLES_SOURCES_PLATFORM}
    )
    list(APPEND LIBANGLE_SOURCES "${LIBANGLE_D3D_FORMAT_TABLES_SOURCES}")
endif()

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
    find_package(X11)
    include_directories(${X11_INCLUDE_DIR})
    list(APPEND LIBANGLE_RENDERER_PLATFORM ${X11_LIBRARIES})
    set(LIBANGLE_RENDERER_COMPILEDEF
        -DANGLE_USE_X11
    )
else()
    set(LIBANGLE_RENDERER_COMPILEDEF )
endif()

add_library(libANGLE STATIC ${LIBANGLE_SOURCES})
target_link_libraries(libANGLE PRIVATE
    angle::common
    angle::compression
    angle::image_util
    angle::gpu_info_util
    angle::translator
    angle::preprocessor
    ${LIBANGLE_RENDERER_PLATFORM}
)
target_include_directories(libANGLE PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/third_party/khronos>")
target_compile_definitions(libANGLE
    PRIVATE -DANGLE_ENABLE_NULL
    PUBLIC 
        -DLIBANGLE_IMPLEMENTATION 
        ${LIBANGLE_RENDERER_COMPILEDEF} 
        -DANGLE_EXPORT=
        -DANGLE_UTIL_EXPORT=
        -DEGLAPI=
        -DGL_APICALL=
        -DGL_API=
        -DANGLE_CAPTURE_ENABLED=0
)
add_library(angle::libANGLE ALIAS libANGLE)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libANGLE
        PRIVATE -DLIBANGLE_UTIL_IMPLEMENTATION
    )
endif()

##########
# libGLESv2
# Modified according to the file src/libGLESv2.gni
list(APPEND LIBGLESV2_SOURCES
    "src/libGLESv2/egl_ext_stubs.cpp"
    "src/libGLESv2/egl_ext_stubs_autogen.h"
    "src/libGLESv2/egl_stubs.cpp"
    "src/libGLESv2/egl_stubs_autogen.h"
    "src/libGLESv2/entry_points_egl_autogen.cpp"
    "src/libGLESv2/entry_points_egl_autogen.h"
    "src/libGLESv2/entry_points_egl_ext_autogen.cpp"
    "src/libGLESv2/entry_points_egl_ext_autogen.h"
    "src/libGLESv2/entry_points_gles_1_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_1_0_autogen.h"
    "src/libGLESv2/entry_points_gles_2_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_2_0_autogen.h"
    "src/libGLESv2/entry_points_gles_3_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_0_autogen.h"
    "src/libGLESv2/entry_points_gles_3_1_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_1_autogen.h"
    "src/libGLESv2/entry_points_gles_3_2_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_2_autogen.h"
    "src/libGLESv2/entry_points_gles_ext_autogen.cpp"
    "src/libGLESv2/entry_points_gles_ext_autogen.h"
    "src/libGLESv2/global_state.cpp"
    "src/libGLESv2/global_state.h"
    "src/libGLESv2/libGLESv2_autogen.cpp"
    "src/libGLESv2/proc_table_egl.h"
    "src/libGLESv2/proc_table_egl_autogen.cpp"
    "src/libGLESv2/resource.h"
    "src/libGLESv2/libGLESv2_autogen.def"
)
add_library(libGLESv2 ${LIBGLESV2_SOURCES})
target_link_libraries(libGLESv2 PRIVATE angle::common angle::libANGLE)
target_compile_definitions(libGLESv2
    PRIVATE -DLIBGLESV2_IMPLEMENTATION
    PUBLIC
        "-DGL_GLES_PROTOTYPES=1"
        "-DGL_GLEXT_PROTOTYPES"
        "-DEGL_EGL_PROTOTYPES=1"
        "-DEGL_EGLEXT_PROTOTYPES"
)
if(BUILD_SHARED_LIBS)
else()
    if(WIN32)
        target_compile_definitions(libGLESv2 PRIVATE
                "-DGL_API="
                "-DGL_APICALL="
                "-DEGLAPI="
        )
    else()
        target_compile_definitions(libGLESv2 PRIVATE
                "-DGL_API=__attribute__((visibility(\"default\")))"
                "-DGL_APICALL=__attribute__((visibility(\"default\")))"
                "-DEGLAPI=__attribute__((visibility(\"default\")))"
        )
    endif()
endif()

target_include_directories(libGLESv2 PUBLIC "$<INSTALL_INTERFACE:include>")

##########
# libEGL
if(WIN32)
    set(libEGL_def
        "src/libEGL/libEGL_autogen.def"
    )
endif()
add_library(libEGL
    "src/libEGL/egl_loader_autogen.h"
    "src/libEGL/libEGL_autogen.cpp"
    "src/libEGL/resource.h"
    "src/libGLESv2/entry_points_egl_autogen.h"
    "src/libGLESv2/entry_points_egl_ext_autogen.h"
    ${libEGL_def}
)

target_link_libraries(libEGL PRIVATE angle::common angle::libANGLE libGLESv2)
target_include_directories(libEGL PUBLIC "$<INSTALL_INTERFACE:include>" "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>")
target_compile_definitions(libEGL
    PRIVATE
        "-DLIBEGL_IMPLEMENTATION"
    PUBLIC
        "-DGL_GLES_PROTOTYPES=1"
        "-DGL_GLEXT_PROTOTYPES"
        "-DEGL_EGL_PROTOTYPES=1"
        "-DEGL_EGLEXT_PROTOTYPES"
)
add_library(GL_VISIBILITY INTERFACE)
if(WIN32)
    target_compile_definitions(GL_VISIBILITY INTERFACE
                "-DGL_API="
                "-DGL_APICALL=")
else()
    target_compile_definitions(GL_VISIBILITY INTERFACE
                "-DGL_API=__attribute__((visibility(\"default\")))"
                "-DGL_APICALL=__attribute__((visibility(\"default\")))")
endif()
target_link_libraries(libEGL PRIVATE GL_VISIBILITY)
target_link_libraries(libGLESv2 PRIVATE GL_VISIBILITY)

if(WIN32)
    target_compile_definitions(libEGL PRIVATE
            "-DEGLAPI="
    )
else()
    target_compile_definitions(libEGL PRIVATE
            "-DEGLAPI=__attribute__((visibility(\"default\")))"
    )
endif()

if(NOT BUILD_SHARED_LIBS)
    add_definitions("-DANGLE_EXPORT=" "-DANGLE_UTIL_EXPORT=" "-DEGLAPI=" "-DGL_APICALL=" "-DGL_API=")
endif()

SET_TARGET_PROPERTIES(libANGLE PROPERTIES PREFIX "")
SET_TARGET_PROPERTIES(libGLESv2 PROPERTIES PREFIX "")
SET_TARGET_PROPERTIES(libEGL PROPERTIES PREFIX "")

install(TARGETS libEGL libGLESv2 libANGLE angle_common angle_compression_utils angle_image_util angle_gpu_info_util angle_translator angle_preprocessor GL_VISIBILITY EXPORT ANGLEExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(WINDOWS_DESKTOP)
    install(TARGETS angle_renderer_d3d angle_renderer_win32 angle_renderer_opengl EXPORT ANGLEExport
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
elseif(WINDOWS_STORE)
    install(TARGETS angle_renderer_d3d angle_renderer_winrt EXPORT ANGLEExport
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
else()
    install(TARGETS angle_renderer_opengl EXPORT ANGLEExport
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
endif()

install(EXPORT ANGLEExport FILE unofficial-angle-config.cmake NAMESPACE unofficial::angle:: DESTINATION share/unofficial-angle)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY include/
        DESTINATION include
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.inc"
        PATTERN "CL" EXCLUDE
        PATTERN "GLSLANG" EXCLUDE
        PATTERN "egl.h" EXCLUDE
        PATTERN "eglext.h" EXCLUDE
        PATTERN "eglplatform.h" EXCLUDE
        PATTERN "KHR" EXCLUDE
        PATTERN "WGL" EXCLUDE
        PATTERN "export.h" EXCLUDE
    )
endif()
