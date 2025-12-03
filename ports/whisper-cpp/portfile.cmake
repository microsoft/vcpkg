vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/whisper.cpp
    REF v${VERSION}
    SHA512 d858509b22183b885735415959fc996f0f5ca315aaf40b8640593c4ce881c88fec3fcd16e9a3adda8d1177feed01947fb4c1beaf32d7e4385c5f35a024329ef5
    HEAD_REF master
    PATCHES
        cmake-config.diff
        pkgconfig.diff
)

file(READ "${SOURCE_PATH}/CMakeLists.txt" CMAKE_CONTENT)
string(REPLACE "install(TARGETS whisper LIBRARY PUBLIC_HEADER)" "install(TARGETS whisper LIBRARY RUNTIME PUBLIC_HEADER)" CMAKE_CONTENT "${CMAKE_CONTENT}")
string(REPLACE "    else()
        add_subdirectory(ggml)" "    else()
        set(BUILD_SHARED_LIBS OFF)
        add_subdirectory(ggml)
        set(BUILD_SHARED_LIBS ON)" CMAKE_CONTENT "${CMAKE_CONTENT}")
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${CMAKE_CONTENT}")

file(READ "${SOURCE_PATH}/ggml/CMakeLists.txt" GGML_CONTENT)
string(REPLACE "install(TARGETS" "#install(TARGETS" GGML_CONTENT "${GGML_CONTENT}")
file(WRITE "${SOURCE_PATH}/ggml/CMakeLists.txt" "${GGML_CONTENT}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # updating bindings/javascript/package.json
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
        -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
        -DWHISPER_ALL_WARNINGS=OFF
        -DWHISPER_BUILD_EXAMPLES=ON
        -DWHISPER_BUILD_SERVER=OFF
        -DWHISPER_BUILD_TESTS=OFF
        -DWHISPER_CCACHE=OFF
        -DWHISPER_USE_SYSTEM_GGML=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/whisper")
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/models/convert-pt-to-ggml.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
