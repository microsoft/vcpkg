if(MSVC AND CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
    add_compile_options(/Gy)
endif()

# https://gitlab.kitware.com/cmake/cmake/-/issues/25635
if(CMAKE_VERSION VERSION_EQUAL "3.28.0" OR CMAKE_VERSION VERSION_EQUAL "3.28.1")
    list(APPEND CMAKE_IGNORE_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/freetype")
endif()
