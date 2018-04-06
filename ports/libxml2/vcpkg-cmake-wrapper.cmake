_find_package(${ARGS})
if(LibXml2_FOUND)
    find_package(LibLZMA)
    list(APPEND LIBXML2_LIBRARIES ${LIBLZMA_LIBRARIES})
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND LIBXML2_LIBRARIES
            debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/libiconv.lib
            optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libiconv.lib
            debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/libcharset.lib
            optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libcharset.lib
            ws2_32)
    endif()
endif()
