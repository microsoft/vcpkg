cmake_minimum_required(VERSION 3.14)

project(nayuki-qr-code-generator LANGUAGES CXX)

include(GNUInstallDirs)

add_library(nayuki-qr-code-generator qrcodegen.cpp)
target_compile_features(nayuki-qr-code-generator PUBLIC cxx_std_11)
target_include_directories(
    nayuki-qr-code-generator
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(FILES qrcodegen.hpp DESTINATION include)

install(TARGETS nayuki-qr-code-generator EXPORT unofficial-nayuki-qr-code-generator-config)

install(
    EXPORT unofficial-nayuki-qr-code-generator-config
    NAMESPACE unofficial::nayuki-qr-code-generator::
    DESTINATION share/nayuki-qr-code-generator
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
