vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH source_path
    REPO WebAssembly/wabt
    REF "${VERSION}"
    SHA512 5b8c2b9cc7b96c0964a8c33fd13a3f0fdeb665598d6a55f47264f285f52f646865613b6745c20ebecb50f3358c454aaef6737a895bc64009c4ef06ef6ce14a7e
    HEAD_REF main
)

# wabt enables wasm-rt-impl iff setjmp.h is found by `check_include_file`.
# It does not use this variable otherwise.
vcpkg_check_features(OUT_FEATURE_OPTIONS feature_options
                     FEATURES
                     tools BUILD_TOOLS
                     wasm-rt-impl HAVE_SETJMP_H)

vcpkg_cmake_configure(
    SOURCE_PATH "${source_path}"
    OPTIONS
        ${feature_options}
        -DBUILD_LIBWASM=OFF
        -DBUILD_TESTS=OFF
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/include_picosha2.cmake"
        -DUSE_INTERNAL_SHA256=ON
        -DWABT_INSTALL_CMAKEDIR=share/wabt
        -DWITH_EXCEPTIONS=ON
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            spectest-interp
            wasm-decompile
            wasm-interp
            wasm-objdump
            wasm-stats
            wasm-strip
            wasm-validate
            wasm2c
            wasm2wat
            wast2json
            wat-desugar
            wat2wasm
        AUTO_CLEAN
    )
endif ()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${source_path}/LICENSE")
