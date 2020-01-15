include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(TRIPLET_SYSTEM_ARCH MATCHES "arm" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR VCPKG_LIBRARY_LINKAGE STREQUAL static)

    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

elseif(VCPKG_TARGET_IS_WINDOWS)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "http://www.advsofteng.net/chartdir_cpp_win.zip"
        FILENAME "chartdir_cpp_win-6.3.1.zip"
        SHA512 e9841d4416c833f57439a36cb981a9c320884c655f8278a22690f05a215c87f0bba83406b45e03ea384c015a4619852c7a9b36dcc9dbd7d531dee1c07b5cffe9
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 6.3.1
    )

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBDIR "${SOURCE_PATH}/lib64")
    else()
        set(LIBDIR "${SOURCE_PATH}/lib32")
    endif()

    file(COPY "${LIBDIR}/chartdir60.dll"  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY "${LIBDIR}/chartdir60.lib"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${LIBDIR}/chartdir60.dll"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY "${LIBDIR}/chartdir60.lib"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    set(CHARTDIR_LIB "chartdir60.lib")

elseif(VCPKG_TARGET_IS_OSX)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "https://www.advsofteng.net/chartdir_cpp_mac.tar.gz"
        FILENAME "chartdir_cpp_mac-6.3.1.tar.gz"
        SHA512 d7364b42ed7c5dd2f89ed8692ed0df1ec952216ba24f8afa8e039641f3296f23c9ff6391e3e0dcd3bfdb9e6898c21a8281aa2803fbee33c7197c1df271a0edf7
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 6.3.1
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.6.dylib"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${SOURCE_PATH}/lib/libchartdir.6.dylib"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    set(CHARTDIR_LIB "libchartdir.6.dylib")

elseif(VCPKG_TARGET_IS_LINUX)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "http://www.advsofteng.net/chartdir_cpp_linux_64.tar.gz"
            FILENAME "chartdir_cpp_linux_64-6.3.1.tar.gz"
            SHA512 e6a3acee3cc5f38304ffa0d3704b1365fcc7a60c8bb688f121caa31efa568b74598b4e10379e84200888d9d8dc3cd7a6a24a944c2d63ca5a146162854c6222a9
        )

    else()

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "http://www.advsofteng.net/chartdir_cpp_linux.tar.gz"
            FILENAME "chartdir_cpp_linux-6.3.1.tar.gz"
            SHA512 0a2f2d7c8d53c2f06c302a837f286826b4f48cc5f5bdb55c4de23337bc4188d1652625aee2c8061561d9b5bdef5e0e2a4cdd176d44ca60c1f730e4f38299c5a0
        )

    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 6.3.1
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.6.0.3"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.6.0.3"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    set(CHARTDIR_LIB "libchartdir.so.6.0.3")

    file(COPY ${SOURCE_PATH}/lib/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/share/chartdir)

endif()

file(GLOB HEADERS "${SOURCE_PATH}/include/*.h")
file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/chartdir)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/chartdir.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/chartdir/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in ${CURRENT_PACKAGES_DIR}/share/chartdir/chartdir-config.cmake @ONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/chartdir)
