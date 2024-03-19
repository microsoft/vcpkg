include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(OpenSSL)
if(NOT WIN32)
    find_dependency(Threads)
endif()

if(NOT TARGET unofficial::libqcow::libqcow)
    add_library(unofficial::libqcow::libqcow UNKNOWN IMPORTED)

    set_target_properties(unofficial::libqcow::libqcow PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:OpenSSL::Crypto>" "$<LINK_ONLY:ZLIB::ZLIB>"
    )

    if(NOT WIN32)
        set_property(TARGET unofficial::libqcow::libqcow APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES Threads::Threads
        )
    endif()

    find_library(VCPKG_LIBQCOW_LIBRARY_RELEASE NAMES qcow libqcow PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBQCOW_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libqcow::libqcow APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libqcow::libqcow PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBQCOW_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBQCOW_LIBRARY_DEBUG NAMES qcow libqcow PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBQCOW_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libqcow::libqcow APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libqcow::libqcow PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBQCOW_LIBRARY_DEBUG}")
    endif()
endif()
