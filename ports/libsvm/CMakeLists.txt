cmake_minimum_required(VERSION 3.14)

project(libsvm LANGUAGES C CXX)

include(GNUInstallDirs)

set(libsvm_sources svm.cpp)
if (WIN32)
    list(APPEND libsvm_sources svm.def)
endif ()

add_library(libsvm ${libsvm_sources})

target_include_directories(
    libsvm
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(libsvm PROPERTIES PUBLIC_HEADER svm.h)

install(TARGETS libsvm EXPORT unofficial-libsvm-config)

install(
    EXPORT unofficial-libsvm-config
    NAMESPACE unofficial::libsvm::
    DESTINATION share/unofficial-libsvm
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
