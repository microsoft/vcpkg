vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nnqe/qe6502
    REF v1.0.0
    SHA512 035dd6c9ff345f112eb086593d145f7ff45785f6bb18f6f2f053eb9e3f869f37c212d3a118e24aa374daa72d8eba89d67f0ffc4f98c3e74af839ee51c3a1057c
    HEAD_REF main
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(QE6502_BUILD_STATIC OFF)
    set(QE6502_BUILD_SHARED ON)
else()
    set(QE6502_BUILD_STATIC ON)
    set(QE6502_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQE6502_BUILD_STATIC=${QE6502_BUILD_STATIC}
        -DQE6502_BUILD_SHARED=${QE6502_BUILD_SHARED}
        -DQE6502_BUILD_CPP=ON
        -DQE6502_BUILD_TESTS=OFF
        -DQE6502_BUILD_TOOLS=OFF
        -DQE6502_BUILD_CSHARP=OFF
        -DQE6502_BUILD_RUST=OFF
        -DQE6502_BUILD_JAVA=OFF
        -DQE6502_BUILD_PYTHON=OFF
        -DQE6502_BUILD_WASM=OFF
        -DQE6502_INSTALL=ON
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/qe6502/qe6502_version.h"
        "#endif /* QE6502_VERSION_H */"
        "#ifndef QE6502_SHARED\n#   define QE6502_SHARED 1\n#endif\n\n#ifndef QE6502_CPP_SHARED\n#   define QE6502_CPP_SHARED 1\n#endif\n\n#endif /* QE6502_VERSION_H */"
    )
else()
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/qe6502/qe6502_version.h"
        "#endif /* QE6502_VERSION_H */"
        "#ifndef QE6502_STATIC\n#   define QE6502_STATIC 1\n#endif\n\n#endif /* QE6502_VERSION_H */"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME qe6502
    CONFIG_PATH lib/cmake/qe6502
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
