if(VCPKG_TARGET_IS_EMSCRIPTEN)
    message(FATAL_ERROR "tinyusdz is not supported on Emscripten")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MGTheTrain/tinyusdz       
    REF v0.9.1
    SHA512 5c4b6bb8407940b1435a4899652d5f536afc3e7c7437e2d49c3662a8d89413efdd4e1abcfce5022eab3b8ada02d8feeabb556ecbc4b15e7405e3ba7b894d2b41
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYUSDZ_BUILD_TESTS=OFF
        -DTINYUSDZ_BUILD_EXAMPLES=OFF
        -DTINYUSDZ_BUILD_BENCHMARKS=OFF
        -DTINYUSDZ_WITH_OPENSUBDIV=OFF
        -DTINYUSDZ_WITH_EXR=OFF
        -DTINYUSDZ_WITH_AUDIO=OFF
        -DTINYUSDZ_WITH_USDMTLX=OFF
        -DTINYUSDZ_WITH_PXR_COMPAT_API=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/tinyusdz PACKAGE_NAME tinyusdz)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Expose TINYUSDZ_INCLUDE_DIR variable for consumers using target_include_directories
file(APPEND "${CURRENT_PACKAGES_DIR}/share/tinyusdz/tinyusdzConfig.cmake" "
get_filename_component(_TINYUSDZ_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}/../../..\" ABSOLUTE)
set(TINYUSDZ_INCLUDE_DIR \"\${_TINYUSDZ_PREFIX}/include/tinyusdz\")
")

# Add after vcpkg_install_copyright:
file(WRITE "${CURRENT_PACKAGES_DIR}/share/tinyusdz/usage"
"tinyusdz provides the following CMake targets:\n\
\n\
    find_package(tinyusdz CONFIG REQUIRED)\n\
    target_link_libraries(main PRIVATE tinyusdz::tinyusdz_static)\n\
    target_include_directories(main PRIVATE \${TINYUSDZ_INCLUDE_DIR})\n"
)