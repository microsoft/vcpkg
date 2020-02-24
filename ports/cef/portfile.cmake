set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_fail_port_install(ON_ARCH "x64" "arm" ON_TARGET "Linux" "osx" "uwp" )

set(platform windows)
set(architecture 32)
set(windows32_sha512
    c45c885719f1b4cb0aaa904572c57307365d05ec77dee1d0e9eec36a5e6444e47043a6dad27368a573d7544bf1140178c21157705260c8ebba291daea5bc7634
)

vcpkg_download_distfile(ARCHIVE
    URLS "http://opensource.spotify.com/cefbuilds/cef_binary_79.1.36%2Bg90301bd%2Bchromium-79.0.3945.130_${platform}${architecture}.tar.bz2"
    FILENAME cef_dist.tar.bz2
    SHA512 ${${platform}${architecture}_sha512}
)

vcpkg_find_acquire_program(7Z)

get_filename_component(ARCHIVE_DIRECTORY ${ARCHIVE} DIRECTORY)

vcpkg_execute_required_process(
    COMMAND ${7Z} x ${ARCHIVE} -aoa
    WORKING_DIRECTORY ${ARCHIVE_DIRECTORY}
    LOGNAME extract-cef.log
)

get_filename_component(ARCHIVE_NAME_WLE ${ARCHIVE} NAME_WLE)

file(MAKE_DIRECTORY ${ARCHIVE_DIRECTORY}/cef)
vcpkg_execute_required_process(
    COMMAND ${7Z} x ${ARCHIVE_DIRECTORY}/${ARCHIVE_NAME_WLE} -aoa
    WORKING_DIRECTORY ${ARCHIVE_DIRECTORY}/cef
    LOGNAME extract-cef.log
)

set(CEF_PATH
    ${ARCHIVE_DIRECTORY}/cef/cef_binary_79.1.36+g90301bd+chromium-79.0.3945.130_${platform}${architecture}
)

vcpkg_apply_patches(
    SOURCE_PATH ${CEF_PATH}/libcef_dll
    PATCHES 0001_force_static_library.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${CEF_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${CEF_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_apply_patches(
    SOURCE_PATH ${CEF_PATH}
    PATCHES 0002_remove_cef_root_usage.patch
)

if (WIN32)
    # Use d3dcompiler_47.dll from our system
    # Version from the Spotify's build uses outdated CRT
    file(REMOVE ${CEF_PATH}/Release/d3dcompiler_47.dll)
    file(REMOVE ${CEF_PATH}/Debug/d3dcompiler_47.dll)

    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(sys System32)
    else()
        set(sys SysWoW64)
    endif()

    if (NOT EXISTS $ENV{SystemRoot}/${sys}/d3dcompiler_47.dll)
        message(FATAL_ERROR "d3dcompiler_47.dll is missing")
    endif()
endif()

file(INSTALL ${CEF_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(INSTALL ${CEF_PATH}/cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share RENAME ${PORT})
file(INSTALL ${CEF_PATH}/cmake/FindCEF.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME CEFConfig.cmake)

file(INSTALL ${CEF_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${CEF_PATH}/Resources DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CEF_PATH}/Release DESTINATION ${CURRENT_PACKAGES_DIR}/bin RENAME ${PORT})
file(INSTALL ${CEF_PATH}/Debug DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin RENAME ${PORT})

foreach(cfg_prefix "" "/debug")
    file(GLOB libs ${CURRENT_PACKAGES_DIR}${cfg_prefix}/bin/${PORT}/*.lib)
    file(INSTALL ${libs} DESTINATION ${CURRENT_PACKAGES_DIR}${cfg_prefix}/lib)
    file(REMOVE ${libs})
endforeach()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/libcef_dll DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CEF_PATH}/libcef_dll DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(GLOB_RECURSE cc
    ${CURRENT_PACKAGES_DIR}/include/*.cc
    ${CURRENT_PACKAGES_DIR}/include/*.txt
)
file(REMOVE ${cc})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libcef_dll/base)

file(REMOVE_RECURSE ${CEF_PATH})
file(REMOVE ${ARCHIVE_DIRECTORY}/${ARCHIVE_NAME_WLE})
