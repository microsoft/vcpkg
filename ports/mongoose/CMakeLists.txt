cmake_minimum_required(VERSION 3.14)

project(mongoose C)

include(GNUInstallDirs)

option(ENABLE_SSL "Build with openssl support" OFF)
option(ENABLE_PACK "Build pack for embedding read-only filesystems" OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(mongoose mongoose.c)
target_include_directories(mongoose PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
set_target_properties(mongoose PROPERTIES PUBLIC_HEADER mongoose.h)

set(INSTALL_TARGETS mongoose)
if (ENABLE_PACK)
    add_executable(pack test/pack.c)
    list(APPEND INSTALL_TARGETS pack)
    target_compile_definitions(mongoose PRIVATE MG_ENABLE_PACKED_FS=1)
endif()

if (ENABLE_SSL)
    find_package(OpenSSL REQUIRED)
    target_compile_options(mongoose PRIVATE -DMG_ENABLE_SSL)
    target_link_libraries(mongoose PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

install(TARGETS ${INSTALL_TARGETS} EXPORT unofficial-mongoose-config)

install(
    EXPORT unofficial-mongoose-config
    NAMESPACE unofficial::mongoose::
    DESTINATION share/unofficial-mongoose
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
