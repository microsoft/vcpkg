set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF 9a4acb374565f4146b8d6eb1cffdcd7d437d1ba2
    SHA512 091a794baf669616ee20dc19d0232e64456c07cd50cbe6d81aa68b98f178801be1b62da9eea417e7a563a6b73bb3136777f860c756270569676fb760f2e751ed
    HEAD_REF master
    PATCHES
        ggml-test.diff
)

set(options "")
if("pkgconfig" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND options
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/simple"
    OPTIONS
        ${options}
)
vcpkg_cmake_build()
