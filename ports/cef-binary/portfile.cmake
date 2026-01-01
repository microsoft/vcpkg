vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(CEF_VERSION "143.0.13+g30cb3bd+chromium-143.0.7499.170")
set(CEF_ARCHIVE "cef_binary_${CEF_VERSION}_windows64.tar.bz2")
set(CEF_URL "https://cef-builds.spotifycdn.com/${CEF_ARCHIVE}")

set(CEF_SHA512 "1a702222c60bfae6dd1a3d87b1410fac11b9db83182a13831930016ba37b8cdd8d0f7f1d86216f6a0ae7c205f7099c64ec0b8657e149cd7e1dccfea1717c90f4")

vcpkg_download_distfile(ARCHIVE
    URLS "${CEF_URL}"
    FILENAME "${CEF_ARCHIVE}"
    SHA512 "${CEF_SHA512}"
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(NOT EXISTS "${SOURCE_PATH}/Release" OR NOT EXISTS "${SOURCE_PATH}/Debug")
    set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
endif()

if(NOT EXISTS "${SOURCE_PATH}/include")
    message(FATAL_ERROR "${PORT}: include directory not found in the extracted archive.")
endif()
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

function(_cef_install_cfg cfg is_debug)
    if(NOT EXISTS "${SOURCE_PATH}/${cfg}")
        return()
    endif()

    if(is_debug)
        set(_lib_dst "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(_bin_dst "${CURRENT_PACKAGES_DIR}/debug/bin")
    else()
        set(_lib_dst "${CURRENT_PACKAGES_DIR}/lib")
        set(_bin_dst "${CURRENT_PACKAGES_DIR}/bin")
    endif()

    file(MAKE_DIRECTORY "${_lib_dst}" "${_bin_dst}")

    file(GLOB _implibs "${SOURCE_PATH}/${cfg}/*.lib")
    if(_implibs)
        file(INSTALL ${_implibs} DESTINATION "${_lib_dst}")
    endif()

    set(_redist_dlls
        "chrome_elf.dll"
        "d3dcompiler_47.dll"
        "dxcompiler.dll"
        "dxil.dll"
        "libEGL.dll"
        "libGLESv2.dll"
    )
    set(_redist_dst "${CURRENT_PACKAGES_DIR}/share/${PORT}/redist/${cfg}")

    file(GLOB _runtime_files
        "${SOURCE_PATH}/${cfg}/*.dll"
        "${SOURCE_PATH}/${cfg}/*.pak"
        "${SOURCE_PATH}/${cfg}/*.dat"
        "${SOURCE_PATH}/${cfg}/*.bin"
        "${SOURCE_PATH}/${cfg}/*.json"
    )

    foreach(_f IN LISTS _runtime_files)
        get_filename_component(_n "${_f}" NAME)
        list(FIND _redist_dlls "${_n}" _is_redist)
        if(_is_redist GREATER -1)
            file(MAKE_DIRECTORY "${_redist_dst}")
            file(INSTALL "${_f}" DESTINATION "${_redist_dst}")
        else()
            file(INSTALL "${_f}" DESTINATION "${_bin_dst}")
        endif()
    endforeach()

    foreach(_sub IN ITEMS locales swiftshader)
        if(EXISTS "${SOURCE_PATH}/${cfg}/${_sub}")
            file(INSTALL "${SOURCE_PATH}/${cfg}/${_sub}" DESTINATION "${_bin_dst}")
        endif()
    endforeach()
endfunction()

_cef_install_cfg("Release" OFF)
_cef_install_cfg("Debug" ON)

if(EXISTS "${SOURCE_PATH}/Resources")
    file(INSTALL "${SOURCE_PATH}/Resources" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/unofficial-cef")
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-cef-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-cefConfig.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-cef"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(EXISTS "${SOURCE_PATH}/LICENSE.txt")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
elseif(EXISTS "${SOURCE_PATH}/LICENSE")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
else()
    message(FATAL_ERROR "${PORT}: could not find LICENSE file in the extracted archive.")
endif()
