#[[
    vcpkg overloads find_package().
    mysql-connector-cpp overloads find_dependency().

    To force a strict order of desired effects and to prevent undesired effects,
    without heavy patching:
    1. All pristine find_package() must be done here first.
       This is with pristine vcpkg toolchain find_package()/find_dependency().
    2. After that, find_package is overloaded to prevent loading of CMakeFindDependenyMacro.
    3. mysql-connector-cpp installs and uses its custom find_dependency().
#]]

set(THREADS_PREFER_PTHREAD_FLAG 1)
find_package(Threads)

find_package(OpenSSL REQUIRED)

find_package(Protobuf CONFIG REQUIRED)
#add_library(ext::protobuf ALIAS protobuf::libprotobuf)
add_library(ext::protobuf-lite ALIAS protobuf::libprotobuf-lite)
if(NOT TARGET ext::protoc)
    add_executable(ext::protoc IMPORTED)
    set_target_properties(ext::protoc PROPERTIES IMPORTED_LOCATION "${WITH_PROTOC}")
endif()

find_package(RapidJSON CONFIG REQUIRED)
add_library(RapidJSON::rapidjson ALIAS RapidJSON)

find_package(ZLIB REQUIRED)
add_library(ext::z ALIAS ZLIB::ZLIB)

find_package(lz4 REQUIRED)
add_library(ext::lz4 ALIAS lz4::lz4)

find_package(zstd REQUIRED)
add_library(ext::zstd ALIAS zstd::libzstd)

if(WITH_JDBC)
    find_package(unofficial-libmysql REQUIRED)
    find_path(errmsg_include_dir NAMES errmsg.h PATH_SUFFIXES mysql)
    set_property(TARGET unofficial::libmysql::libmysql APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${errmsg_include_dir}")
    add_library(MySQL::client ALIAS unofficial::libmysql::libmysql)

    file(READ "${errmsg_include_dir}/mysql_version.h" version_h)
    if(NOT version_h MATCHES "#define +MYSQL_SERVER_VERSION +\"([^\"]+)\"")
        message(FATAL_ERROR "Failed to detect libmysql version")
    endif()
    set(MYSQL_VERSION "${CMAKE_MATCH_1}")
    if(NOT version_h MATCHES "#define +MYSQL_VERSION_ID +([0-9]+)")
        message(FATAL_ERROR "Failed to detect libmysql version ID")
    endif()
    set(MYSQL_NUM_VERSION "${CMAKE_MATCH_1}")
endif()

set(known_packages Threads OpenSSL Protobuf RapidJSON ZLIB lz4 zstd unofficial-libmysql)
cmake_policy(SET CMP0057 NEW)
macro(find_package NAME)
    if(NOT "${NAME}" IN_LIST known_packages)
        message(SEND_ERROR "find_package(${NAME}) not handled in ${CMAKE_CURRENT_LIST_FILE}")
    endif()
endmacro()
