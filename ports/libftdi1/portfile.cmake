vcpkg_download_distfile(ARCHIVE
    URLS "https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.5.tar.bz2"
    FILENAME "libftdi1-1.5.tar.bz2"
    SHA512 c525b2ab6aff9ef9254971ae7d57f3549a36a36875765c48f947d52532814a2a004de1232389d4fe824a8c8ab84277b08427308573476e1da9b7db83db802f6f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE 1.5
    PATCHES
        cmake-version.diff
        disable-config-script.diff
        linkage.diff
        libdir.diff
        libftdipp1.diff
        libusb.diff
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}/src")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        cpp     FTDIPP
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DBUILD_TESTS=OFF
        -DCMAKE_CXX_STANDARD=11
        -DDOCUMENTATION=OFF
        -DEXAMPLES=OFF
        -DFTDI_EEPROM=OFF
        -DLIB_SUFFIX=
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DPYTHON_BINDINGS=OFF
        -DSTATICLIBS=${STATICLIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/libftdi1/LibFTDI1Config.cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/libftdi1/LibFTDI1Config-debug.cmake")
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libftdi1)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config.cmake" "/lib/cmake/${PORT}/" "/share/${PORT}/")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config-debug.cmake" "/debug/lib/cmake/${PORT}/" "/share/${PORT}/")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config-debug.cmake" "{_IMPORT_PREFIX}" "{VCPKG_IMPORT_PREFIX}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config-debug.cmake" "{VCPKG_IMPORT_PREFIX}/debug/include/" "{VCPKG_IMPORT_PREFIX}/include/")
    file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config.cmake" release_config)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/LibFTDI1Config.cmake" "
if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES \"^[Dd][Ee][Bb][Uu][Gg]\$\")
    include(\"\${CMAKE_CURRENT_LIST_DIR}/LibFTDI1Config-debug.cmake\")
    return()
endif()
${release_config}"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT "cpp" IN_LIST FEATURES)
    file(REMOVE  "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libftdipp1.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libftdipp1.pc")
endif()

set(file_list "${SOURCE_PATH}/COPYING.LIB")
if("cpp" IN_LIST FEATURES)
    set(file_list "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING.LIB" "${SOURCE_PATH}/COPYING.GPL")
endif()

vcpkg_install_copyright(FILE_LIST ${file_list})
