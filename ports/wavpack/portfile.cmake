vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbry/WavPack
    REF ${VERSION}
    SHA512 7a0b00ee19a784b5a2ae40c1d86ddf47d989b0302ee32e6b2f4db828d632b877566f9bb8c1998d129b022f988966f29db05b7a2b59cefdd5b603292ea20464ec
    PATCHES
        CMakeLists-patch.diff
        config-patch.diff
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
        -DWAVPACK_ENABLE_LIBCRYPTO=OFF
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

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wavpack.pc" "-lwavpack" "-lwavpackdll")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wavpack.pc" "-lwavpack" "-lwavpackdll")
        endif()
    endif()
endif()

vcpkg_fixup_pkgconfig()
