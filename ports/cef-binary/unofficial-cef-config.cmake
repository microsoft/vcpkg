include_guard(GLOBAL)

get_filename_component(_VCPKG_PKGROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

# Port name that owns the Resources/redist folders.
set(_CEF_PORT "cef-binary")

set(unofficial_cef_resources_dir "${_VCPKG_PKGROOT}/share/${_CEF_PORT}/Resources")
set(unofficial_cef_redist_release_dir "${_VCPKG_PKGROOT}/share/${_CEF_PORT}/redist/Release")
set(unofficial_cef_redist_debug_dir "${_VCPKG_PKGROOT}/share/${_CEF_PORT}/redist/Debug")

if(NOT TARGET unofficial::cef::libcef)
    add_library(unofficial::cef::libcef SHARED IMPORTED GLOBAL)
    set_target_properties(unofficial::cef::libcef PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_PKGROOT}/include"
        IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
        IMPORTED_IMPLIB_RELEASE "${_VCPKG_PKGROOT}/lib/libcef.lib"
        IMPORTED_LOCATION_RELEASE "${_VCPKG_PKGROOT}/bin/libcef.dll"
        IMPORTED_IMPLIB_DEBUG "${_VCPKG_PKGROOT}/debug/lib/libcef.lib"
        IMPORTED_LOCATION_DEBUG "${_VCPKG_PKGROOT}/debug/bin/libcef.dll"
    )
endif()
