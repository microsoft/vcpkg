cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0057 NEW)
set(z_vcpkg_liblzma_fixup_needed 0)
if(NOT "CONFIG" IN_LIST ARGS AND NOT "NO_MODULE" IN_LIST ARGS AND NOT CMAKE_DISABLE_FIND_PACKAGE_LibLZMA)
    get_filename_component(z_vcpkg_liblzma_prefix "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
    get_filename_component(z_vcpkg_liblzma_prefix "${z_vcpkg_liblzma_prefix}" DIRECTORY)
    find_path(LIBLZMA_INCLUDE_DIR NAMES lzma.h PATHS "${z_vcpkg_liblzma_prefix}/include" NO_DEFAULT_PATH)
    # liblzma doesn't use a debug postfix, but FindLibLZMA.cmake expects it 
    find_library(LIBLZMA_LIBRARY_RELEASE NAMES lzma PATHS "${z_vcpkg_liblzma_prefix}/lib" NO_DEFAULT_PATH)
    find_library(LIBLZMA_LIBRARY_DEBUG NAMES lzma PATHS "${z_vcpkg_liblzma_prefix}/debug/lib" NO_DEFAULT_PATH)
    unset(z_vcpkg_liblzma_prefix)
    if(CMAKE_VERSION VERSION_LESS 3.16)
        # Older versions of FindLibLZMA.cmake need a single lib in LIBLZMA_LIBRARY.
        set(z_vcpkg_liblzma_fixup_needed 1)
        set(LIBLZMA_LIBRARY "${LIBLZMA_LIBRARY_RELEASE}")
    elseif(NOT TARGET LibLZMA::LibLZMA)
        set(z_vcpkg_liblzma_fixup_needed 1)
    endif()
    # Known values, and required. Skip expensive tests.
    set(LIBLZMA_HAS_AUTO_DECODER 1 CACHE INTERNAL "")
    set(LIBLZMA_HAS_EASY_ENCODER 1 CACHE INTERNAL "")
    set(LIBLZMA_HAS_LZMA_PRESET 1 CACHE INTERNAL "")
endif()

_find_package(${ARGS})

if(z_vcpkg_liblzma_fixup_needed)
    include(SelectLibraryConfigurations)
    select_library_configurations(LIBLZMA)
    if(NOT TARGET LibLZMA::LibLZMA)
        # Backfill LibLZMA::LibLZMA to versions of cmake before 3.14
        add_library(LibLZMA::LibLZMA UNKNOWN IMPORTED)
        if(DEFINED LIBLZMA_INCLUDE_DIRS)
            set_target_properties(LibLZMA::LibLZMA PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${LIBLZMA_INCLUDE_DIRS}")
        endif()
        set_property(TARGET LibLZMA::LibLZMA APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(LibLZMA::LibLZMA PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
            IMPORTED_LOCATION_RELEASE "${LIBLZMA_LIBRARY_RELEASE}")
        if(EXISTS "${LIBLZMA_LIBRARY}")
            set_target_properties(LibLZMA::LibLZMA PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                IMPORTED_LOCATION "${LIBLZMA_LIBRARY}")
        endif()
    endif()
    if(LIBLZMA_LIBRARY_DEBUG)
        # Backfill debug variant to versions of cmake before 3.16
        set_property(TARGET LibLZMA::LibLZMA APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(LibLZMA::LibLZMA PROPERTIES IMPORTED_LOCATION_DEBUG "${LIBLZMA_LIBRARY_DEBUG}")
    endif()
endif()
if(LIBLZMA_LIBRARIES AND NOT "Threads::Threads" IN_LIST LIBLZMA_LIBRARIES)
    set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    find_package(Threads)
    list(APPEND LIBLZMA_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
    if(TARGET LibLZMA::LibLZMA)
        set_property(TARGET LibLZMA::LibLZMA APPEND PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads)
    endif()
endif()
unset(z_vcpkg_liblzma_fixup_needed)
cmake_policy(POP)
