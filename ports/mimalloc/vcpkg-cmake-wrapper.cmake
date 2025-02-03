_find_package(${ARGS})

if(CMAKE_CURRENT_LIST_DIR STREQUAL "${MIMALLOC_CMAKE_DIR}/${MIMALLOC_VERSION_DIR}")
    set(MIMALLOC_INCLUDE_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
    # As in vcpkg.cmake
    if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
        set(MIMALLOC_LIBRARY_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")
    else()
        set(MIMALLOC_LIBRARY_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
    endif()
    set(MIMALLOC_OBJECT_DIR "MIMALLOC_OBJECT_DIR-NOTFOUND") # not installed
    set(MIMALLOC_TARGET_DIR "${MIMALLOC_LIBRARY_DIR}")
endif()

if(TARGET mimalloc AND NOT TARGET mimalloc-static)
    add_library(mimalloc-static INTERFACE IMPORTED)
    set_target_properties(mimalloc-static PROPERTIES INTERFACE_LINK_LIBRARIES mimalloc)
elseif(TARGET mimalloc-static AND NOT TARGET mimalloc)
    add_library(mimalloc INTERFACE IMPORTED)
    set_target_properties(mimalloc PROPERTIES INTERFACE_LINK_LIBRARIES mimalloc-static)
endif()
