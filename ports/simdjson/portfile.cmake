vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdjson/simdjson
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 badc5828019e9a0531bd2ce92b66aa8273ea1a31b69ff47f009d1102132a5aad46b4bc3e50ab004d1ec2e63f58dbaf89c018dda6b156b9062cf8f800aad73aa2
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        exceptions SIMDJSON_EXCEPTIONS
        threads    SIMDJSON_ENABLE_THREADS
    INVERTED_FEATURES
        deprecated SIMDJSON_DISABLE_DEPRECATED_API
        utf8-validation SIMDJSON_SKIPUTF8VALIDATION
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMDJSON_DEVELOPER_MODE=OFF
        -DSIMDJSON_SANITIZE_UNDEFINED=OFF
        -DSIMDJSON_SANITIZE=OFF
        -DSIMDJSON_SANITIZE_THREADS=OFF
        -DSIMDJSON_DEVELOPMENT_CHECKS=OFF
        -DSIMDJSON_VERBOSE_LOGGING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SIMDJSON_HEADER "${CURRENT_PACKAGES_DIR}/include/simdjson.h")
    file(READ "${SIMDJSON_HEADER}" SIMDJSON_HEADER_CONTENTS)
    file(WRITE "${SIMDJSON_HEADER}"
        "#ifndef SIMDJSON_USING_WINDOWS_DYNAMIC_LIBRARY\n"
        "#define SIMDJSON_USING_WINDOWS_DYNAMIC_LIBRARY 1\n"
        "#endif\n"
        "${SIMDJSON_HEADER_CONTENTS}"
    )
endif()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE-MIT"
        "${SOURCE_PATH}/include/simdjson/nonstd/string_view.hpp"
        "${SOURCE_PATH}/include/simdjson/internal/instruction_set.h"
)
