# Unofficial uSockets CMakeLists.txt from Makefile of https://github.com/uNetworking/uSockets/blob/v0.8.8/Makefile
cmake_minimum_required(VERSION 3.25.1)
project(uSockets VERSION ${VERSION} LANGUAGES C CXX)

# options
option(WITH_OPENSSL "enables OpenSSL 1.1+ support"      OFF)
option(WITH_LIBUV   "builds with libuv as event-loop"   OFF)

# global variables
set(uSockets_installable_libs)
set(uSockets_find_dependency_calls)

# target usockets
add_library(uSockets)
list(APPEND uSockets_installable_libs uSockets)
foreach(dir IN ITEMS "src" "src/eventing" "src/crypto" "src/io_uring")
    aux_source_directory(${dir} uSockets_sources)
endforeach()
list(FILTER uSockets_sources INCLUDE REGEX ".+\\.c$")
target_sources(uSockets PRIVATE ${uSockets_sources})
if(WIN32)
    target_link_libraries(uSockets PRIVATE ws2_32)
endif(WIN32)

# target coupling options
add_library(us_target_coupling INTERFACE)
list(APPEND uSockets_installable_libs us_target_coupling)
# global include
target_include_directories(us_target_coupling INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>")

# global std
target_compile_features(us_target_coupling INTERFACE "c_std_11")
if(WITH_OPENSSL)
    target_compile_features(us_target_coupling INTERFACE "cxx_std_17")
else()
    target_compile_features(us_target_coupling INTERFACE "cxx_std_14")
endif()

# ssl
if(WITH_OPENSSL)
    target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_OPENSSL")
    find_package(OpenSSL REQUIRED)
    list(APPEND uSockets_find_dependency_calls "OpenSSL")
    target_link_libraries(us_target_coupling INTERFACE OpenSSL::SSL OpenSSL::Crypto)
else()
    target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_NO_SSL")
endif()

# event-loop
if(WITH_LIBUV)
    target_compile_definitions(us_target_coupling INTERFACE "-DLIBUS_USE_LIBUV")
    find_package(libuv CONFIG REQUIRED)
    list(APPEND uSockets_find_dependency_calls "libuv CONFIG")
    target_link_libraries(us_target_coupling INTERFACE $<IF:$<TARGET_EXISTS:libuv::uv_a>,libuv::uv_a,libuv::uv>)
else()
    if(WIN32)
        message(FATAL_ERROR "Windows should use LIBUV as default event loop")
    elseif(APPLE OR (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD"))
        message("Apple or FreeBSD use KQUEUE as default event loop")
    else()
        message("Use EPOLL as default event loop")
    endif()
endif()

# target crypto
if(WITH_OPENSSL)
    add_library(us_target_crypto OBJECT)
    list(APPEND uSockets_installable_libs us_target_crypto)
    foreach(dir IN ITEMS "src/crypto")
        aux_source_directory(${dir} us_target_crypto_sources)
    endforeach()
    list(FILTER us_target_crypto_sources INCLUDE REGEX ".+\\.cpp$")
    target_sources(us_target_crypto PRIVATE ${us_target_crypto_sources})
    target_link_libraries(us_target_crypto PUBLIC us_target_coupling)
    target_link_libraries(uSockets PRIVATE us_target_crypto)
endif()

# target link
target_link_libraries(uSockets PRIVATE us_target_coupling)

# install init
set(PACKAGE_NAME "unofficial-uSockets")
set(PACKAGE_NAMESPACE "unofficial::uSockets::")
set(PACKAGE_CONFIG_NAME "${PACKAGE_NAME}Config")
set(PACKAGE_INSTALL_SHARE "share/${PACKAGE_NAME}")
set(PACKAGE_INSTALL_INCLUDE "include/${PACKAGE_NAME}")
set(uSockets_targets_name "uSocketsTargets")
set(PACKAGE_CONFIG_TEMPLATE_PATH "${CMAKE_CURRENT_BINARY_DIR}/Config.cmake.in")
file(GLOB PACKAGE_HEADERS "src/*.h")

# install headers
target_include_directories(uSockets PUBLIC "$<INSTALL_INTERFACE:${PACKAGE_INSTALL_INCLUDE}>")
install(FILES ${PACKAGE_HEADERS} DESTINATION "${PACKAGE_INSTALL_INCLUDE}")

# install targets
install(TARGETS ${uSockets_installable_libs}
    EXPORT "${uSockets_targets_name}"
)

install(EXPORT "${uSockets_targets_name}"
    NAMESPACE "${PACKAGE_NAMESPACE}"
    DESTINATION "${PACKAGE_INSTALL_SHARE}"
)

# generate configs
set(PACKAGE_CONFIG_TEMPLATE "@PACKAGE_INIT@\n\n")
string(APPEND PACKAGE_CONFIG_TEMPLATE "include(CMakeFindDependencyMacro)\n")
list(REMOVE_DUPLICATES uSockets_find_dependency_calls)
foreach(dep_call IN LISTS uSockets_find_dependency_calls)
    string(APPEND PACKAGE_CONFIG_TEMPLATE "find_dependency(${dep_call})\n")
endforeach()
string(APPEND PACKAGE_CONFIG_TEMPLATE "\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/${uSockets_targets_name}.cmake\")\n")

file(WRITE "${PACKAGE_CONFIG_TEMPLATE_PATH}" "${PACKAGE_CONFIG_TEMPLATE}")

include(CMakePackageConfigHelpers)
configure_package_config_file("${PACKAGE_CONFIG_TEMPLATE_PATH}"
  "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_CONFIG_NAME}.cmake"
  INSTALL_DESTINATION "${PACKAGE_INSTALL_SHARE}"
)

# install configs
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_CONFIG_NAME}.cmake" DESTINATION ${PACKAGE_INSTALL_SHARE})
