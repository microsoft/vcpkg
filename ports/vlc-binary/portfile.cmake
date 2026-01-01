vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VLC_VERSION "3.0.22")
set(VLC_ARCHIVE "vlc-${VLC_VERSION}-win64.zip")

set(VLC_URL_1 "https://download.videolan.org/pub/videolan/vlc/${VLC_VERSION}/win64/${VLC_ARCHIVE}")
set(VLC_URL_2 "https://get.videolan.org/vlc/${VLC_VERSION}/win64/${VLC_ARCHIVE}")

# SHA512 of vlc-3.0.22-win64.zip
set(VLC_SHA512 "b10dcee7cdfcf51d855cf89962935f183004ccb2cf4185fbda95fd55aa26195d5dce4fc47a9692b480d308e546c779c63df6513a2b6b7891f560d7a03f23ace2")

vcpkg_download_distfile(ARCHIVE
    URLS
        "${VLC_URL_1}"
        "${VLC_URL_2}"
    FILENAME "${VLC_ARCHIVE}"
    SHA512 "${VLC_SHA512}"
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Find libvlc.dll anywhere under the extracted tree, then treat its directory as VLC_ROOT.
file(GLOB_RECURSE _libvlc_dll LIST_DIRECTORIES FALSE
    "${SOURCE_PATH}/libvlc.dll"
    "${SOURCE_PATH}/*/libvlc.dll"
)

if(NOT _libvlc_dll)
    message(FATAL_ERROR "${PORT}: libvlc.dll not found under: ${SOURCE_PATH}")
endif()

list(GET _libvlc_dll 0 _libvlc_dll0)
get_filename_component(VLC_ROOT "${_libvlc_dll0}" DIRECTORY)
message(STATUS "${PORT}: VLC_ROOT=${VLC_ROOT}")

if(NOT EXISTS "${VLC_ROOT}/plugins")
    message(FATAL_ERROR "${PORT}: plugins directory not found at: ${VLC_ROOT}")
endif()

# Install the runtime distribution into share/ so it does not pollute installed/*/bin with many plugin DLLs.
# Keep plugins/ relative to libvlc.dll.
set(_rt_dst "${CURRENT_PACKAGES_DIR}/share/${PORT}/vlc")
file(MAKE_DIRECTORY "${_rt_dst}")
file(INSTALL "${VLC_ROOT}/" DESTINATION "${_rt_dst}")

# Unofficial CMake package that exposes runtime paths (vars only).
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/unofficial-vlc")
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-vlc-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-vlcConfig.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-vlc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Licence file (tolerant)
set(_vlc_license "")
foreach(_cand IN ITEMS COPYING.txt COPYING LICENSE.txt LICENSE)
    if(EXISTS "${VLC_ROOT}/${_cand}")
        set(_vlc_license "${VLC_ROOT}/${_cand}")
        break()
    endif()
endforeach()

if(_vlc_license STREQUAL "")
    message(FATAL_ERROR "${PORT}: could not find a licence file (COPYING*, LICENSE*) in: ${VLC_ROOT}")
endif()

vcpkg_install_copyright(FILE_LIST "${_vlc_license}")
