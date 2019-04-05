_find_package(${ARGS})

find_package(Threads REQUIRED)

set(G3LOG_LIBRARIES Threads::Threads)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND G3LOG_LIBRARIES
        debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/g3logger.lib
        optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/g3logger.lib
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR
       CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    list(APPEND G3LOG_LIBRARIES
        debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/libg3logger.a
        optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libg3logger.a
    )
endif()
