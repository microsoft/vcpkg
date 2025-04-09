cmake_minimum_required(VERSION 3.10)

# Project name
project(WebUILibrary)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)

# Variables for library names, source files, etc.
set(WEBUI_OUT_LIB_NAME "webui-2")

# Conditional compilation for TLS
option(WEBUI_USE_TLS "Enable TLS support" OFF)
if(WEBUI_USE_TLS)
  find_package(OpenSSL REQUIRED)
  set(WEBUI_OUT_LIB_NAME "webui-2-secure")
endif()

# Source files (already filled)
set(SOURCE_FILES
    src/civetweb/civetweb.c
    src/webui.c
)

add_library(webui ${SOURCE_FILES})
target_include_directories(webui PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
target_compile_definitions(webui PUBLIC NDEBUG NO_CACHING NO_CGI USE_WEBSOCKET)
if(BUILD_SHARED_LIBS AND WIN32)
  target_compile_definitions(webui PRIVATE CIVETWEB_DLL_EXPORTS PUBLIC CIVETWEB_DLL_IMPORTS)
endif()
if(WEBUI_USE_TLS)
  target_compile_definitions(webui PUBLIC WEBUI_TLS WEBUI_TLS NO_SSL_DL OPENSSL_API_1_1)
  target_link_libraries(webui PRIVATE OpenSSL::SSL OpenSSL::Crypto)
else()
  target_compile_definitions(webui PUBLIC NO_SSL)
endif()
set_target_properties(webui PROPERTIES
    OUTPUT_NAME ${WEBUI_OUT_LIB_NAME}
    PREFIX "")

install(FILES include/webui.h include/webui.hpp DESTINATION include)

# Install targets
install(TARGETS webui
    EXPORT unofficial-webui
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(EXPORT unofficial-webui
    FILE unofficial-webui-config.cmake
    NAMESPACE unofficial::webui::
    DESTINATION share/unofficial-webui
)
