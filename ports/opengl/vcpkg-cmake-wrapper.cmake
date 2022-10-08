if(NOT WIN32)
    # ignore vcpkg paths.
    list(APPEND CMAKE_IGNORE_PREFIX_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    _find_package(${ARGS})
    list(POP_BACK CMAKE_IGNORE_PREFIX_PATH)
else()
    _find_package(${ARGS})
endif()

