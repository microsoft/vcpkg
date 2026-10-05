cmake_minimum_required(VERSION 3.24)
project(fastlowess-vcpkg VERSION 4.1.0 LANGUAGES NONE)

include(CMakePackageConfigHelpers)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(cargo_profile debug)
    set(cargo_flags)
else()
    set(cargo_profile release)
    set(cargo_flags --release)
endif()
set(cargo_target x86_64-pc-windows-msvc)
set(cargo_dir "${CMAKE_CURRENT_BINARY_DIR}/cargo")
set(cargo_output "${cargo_dir}/${cargo_target}/${cargo_profile}")

add_custom_target(fastlowess-native ALL
    COMMAND "${CMAKE_COMMAND}" -E env
        "RUSTC=${FASTLOWESS_RUSTC}"
        "RUSTFLAGS=-Ctarget-feature=-crt-static"
        "${FASTLOWESS_CARGO}" rustc
        --manifest-path "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/Cargo.toml"
        --package fastlowess-cpp --lib --locked
        --target "${cargo_target}" --target-dir "${cargo_dir}"
        ${cargo_flags} --crate-type=cdylib
    BYPRODUCTS
        "${cargo_output}/fastlowess_cpp.dll"
        "${cargo_output}/fastlowess_cpp.dll.lib"
        "${cargo_output}/fastlowess_cpp.pdb"
    WORKING_DIRECTORY "${FASTLOWESS_SOURCE_DIR}"
    VERBATIM
)

install(FILES "${cargo_output}/fastlowess_cpp.dll" DESTINATION bin)
install(FILES "${cargo_output}/fastlowess_cpp.dll.lib" DESTINATION lib)
install(FILES "${cargo_output}/fastlowess_cpp.pdb" DESTINATION bin OPTIONAL)
install(FILES
    "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess.h"
    "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess.hpp"
    DESTINATION include
)
if(EXISTS "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess_version.h")
    install(FILES "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess_version.h" DESTINATION include)
endif()

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/fastlowessConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfig.cmake"
    INSTALL_DESTINATION share/fastlowess
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfigVersion.cmake"
    DESTINATION share/fastlowess
)