include_guard(GLOBAL)

get_filename_component(_VCPKG_PKGROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

set(_VLC_PORT "vlc-binary")

set(unofficial_vlc_runtime_dir "${_VCPKG_PKGROOT}/share/${_VLC_PORT}/vlc")
set(unofficial_vlc_plugins_dir "${unofficial_vlc_runtime_dir}/plugins")
