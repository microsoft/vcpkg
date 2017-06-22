cmake_minimum_required(VERSION 3.8)
project(angle)

add_compile_options(/d2guard4 /Wv:18 /WX)
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /guard:cf")

add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS -D_HAS_EXCEPTIONS=0 -DNOMINMAX -DANGLE_STANDALONE_BUILD -DANGLE_ENABLE_DEBUG_ANNOTATIONS)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/include/id/commit.h" "#define ANGLE_COMMIT_HASH \"invalid-hash\"\n#define ANGLE_COMMIT_HASH_SIZE 12\n#define ANGLE_COMMIT_DATE \"invalid-date\"\n")

include_directories(include src ${CMAKE_CURRENT_BINARY_DIR}/include)

##########
# numerics
add_library(numerics INTERFACE)
file(GLOB_RECURSE NUMERICS_SOURCES "src/common/third_party/numerics/*.h")
target_sources(numerics INTERFACE ${NUMERICS_SOURCES})
target_include_directories(numerics INTERFACE src/common/third_party/numerics)

##########
# angle_common
file(GLOB ANGLE_COMMON_SOURCES "src/common/*.h" "src/common/*.inl" "src/common/*.cpp")
list(FILTER ANGLE_COMMON_SOURCES EXCLUDE REGEX "_unittest|event_tracer|_linux|_mac")
add_library(angle_common STATIC ${ANGLE_COMMON_SOURCES} ${NUMERICS_SOURCES})
target_link_libraries(angle_common PUBLIC numerics)

##########
# angle_image_util
file(GLOB ANGLE_IMAGE_UTIL_SOURCES "src/image_util/*.h" "src/image_util/*.inl" "src/image_util/*.cpp")
add_library(angle_image_util STATIC ${ANGLE_IMAGE_UTIL_SOURCES})
target_link_libraries(angle_image_util PRIVATE angle_common)

##########
# translator
file(GLOB TRANSLATOR_SOURCES
    "src/compiler/translator/glslang.l"
    "src/compiler/translator/glslang.y"
    "src/compiler/translator/*.h"
    "src/compiler/translator/*.cpp"
    "src/third_party/compiler/ArrayBoundsClamper.cpp"
)
add_library(translator STATIC ${TRANSLATOR_SOURCES})
target_compile_definitions(translator PUBLIC
    -DANGLE_ENABLE_ESSL
    -DANGLE_ENABLE_GLSL
    -DANGLE_ENABLE_HLSL
)
target_link_libraries(translator PRIVATE angle_common)

##########
# preprocessor
file(GLOB PREPROCESSOR_SOURCES
    "src/compiler/preprocessor/*.h"
    "src/compiler/preprocessor/*.cpp"
)
add_library(preprocessor STATIC ${PREPROCESSOR_SOURCES})
target_link_libraries(preprocessor PRIVATE angle_common)

##########
# libANGLE
file(GLOB LIBANGLE_SOURCES
    "src/third_party/systeminfo/SystemInfo.cpp"
    "src/third_party/murmurhash/MurmurHash3.cpp"
    "src/common/event_tracer.cpp"

    "src/libANGLE/*.cpp"
    "src/libANGLE/*.inl"
    "src/libANGLE/*.h"

    "src/libANGLE/renderer/*.cpp"
    "src/libANGLE/renderer/*.inl"
    "src/libANGLE/renderer/*.h"

    "src/libANGLE/renderer/gl/*.cpp"
    "src/libANGLE/renderer/gl/*.inl"
    "src/libANGLE/renderer/gl/*.h"

    "src/libANGLE/renderer/gl/wgl/*.cpp"
    "src/libANGLE/renderer/gl/wgl/*.inl"
    "src/libANGLE/renderer/gl/wgl/*.h"

    "src/libANGLE/renderer/vulkan/*.cpp"
    "src/libANGLE/renderer/vulkan/*.inl"
    "src/libANGLE/renderer/vulkan/*.h"

    "src/libANGLE/renderer/null/*.cpp"
    "src/libANGLE/renderer/null/*.inl"
    "src/libANGLE/renderer/null/*.h"
)
file(GLOB_RECURSE LIBANGLE_D3D_SOURCES "src/libANGLE/renderer/d3d/*.h" "src/libANGLE/renderer/d3d/*.cpp" "src/libANGLE/renderer/d3d/*.inl")
list(FILTER LIBANGLE_SOURCES EXCLUDE REGEX "_unittest")
list(FILTER LIBANGLE_D3D_SOURCES EXCLUDE REGEX "_unittest|winrt")
add_library(libANGLE STATIC ${LIBANGLE_SOURCES} ${LIBANGLE_D3D_SOURCES})
# kernel32.lib;gdi32.lib;winspool.lib;comdlg32.lib;advapi32.lib;shell32.lib;ole32.lib;oleaut32.lib;user32.lib;uuid.lib;odbc32.lib;odbccp32.lib;delayimp.lib;d3d9.lib;dxguid.lib
find_library(D3D9_LIB NAMES d3d9)
find_library(DXGUID_LIB NAMES dxguid)
target_link_libraries(libANGLE PRIVATE angle_common angle_image_util translator ${D3D9_LIB} ${DXGUID_LIB} preprocessor)
target_include_directories(libANGLE PRIVATE "src/third_party/khronos")
target_compile_definitions(libANGLE PUBLIC
    -DANGLE_ENABLE_D3D9
    -DANGLE_ENABLE_D3D11
    -DANGLE_ENABLE_OPENGL
    -DANGLE_ENABLE_VULKAN
    -DANGLE_ENABLE_NULL
)
target_compile_definitions(libANGLE PRIVATE -DLIBANGLE_IMPLEMENTATION)

##########
# libGLESv2
file(GLOB LIBGLESV2_SOURCES "src/libGLESv2/*.h" "src/libGLESv2/*.cpp" "src/libGLESv2/libGLESv2.def")
add_library(libGLESv2 ${LIBGLESV2_SOURCES})
target_link_libraries(libGLESv2 PRIVATE angle_common libANGLE)
target_compile_definitions(libGLESv2 PRIVATE
    -DLIBGLESV2_IMPLEMENTATION
    -DLIBANGLE_IMPLEMENTATION
    -DGL_GLEXT_PROTOTYPES
    "-DANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }"
    -DGL_APICALL=
    -DEGLAPI=
)

##########
# libEGL
add_library(libEGL "src/libEGL/libEGL.def" "src/libEGL/libEGL.cpp" "src/libEGL/libEGL.rc" "src/libEGL/resource.h")
target_link_libraries(libEGL PRIVATE angle_common libANGLE libGLESv2)
target_compile_definitions(libEGL PRIVATE
    -DLIBANGLE_IMPLEMENTATION
    -DGL_GLEXT_PROTOTYPES
    "-DANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }"
    -DGL_APICALL=
    -DEGLAPI=
)


install(TARGETS libEGL libGLESv2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY include/
        DESTINATION include
        FILES_MATCHING PATTERN "*.h"
        PATTERN "GLSLANG" EXCLUDE
        PATTERN "export.h" EXCLUDE
    )
endif()
