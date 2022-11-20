vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbry/WavPack
    REF 89ef99e84333534d9d43093a5264a398b5f1e14a #5.5.0
    SHA512 6d8a46461ea1a9fab129d705dda6167332e98da27b24323cbfba1827339222956e288ca3947b9a1f513d7eb6f957548cfcef717aa5ba5c3d3e43d29f98de3879
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWAVPACK_INSTALL_DOCS=OFF
        -DWAVPACK_BUILD_PROGRAMS=OFF
        -DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF
        -DWAVPACK_BUILD_WINAMP_PLUGIN=OFF
        -DBUILD_TESTING=OFF
        -DWAVPACK_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WavPack)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(WIN32 AND (NOT MINGW))
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wavpack.pc" "-lwavpack" "-lwavpackdll")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wavpack.pc" "-lwavpack" "-lwavpackdll")
    endif()
endif()

vcpkg_fixup_pkgconfig()
