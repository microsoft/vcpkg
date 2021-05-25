vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(TRIPLET_SYSTEM_ARCH MATCHES "arm" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR VCPKG_LIBRARY_LINKAGE STREQUAL static)

    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

elseif(VCPKG_TARGET_IS_WINDOWS)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "http://www.advsofteng.net/chartdir_cpp_win.zip"
        FILENAME "chartdir_cpp_win-7.0.0.zip"
        SHA512 38d9dae641c0341ccee4709138afd37ad4718c34def70a0dc569956bf9c3488d0d66072f604dca4663dc80bd09446a2ba27ef3806fc3b87dda6aaa5453a7316f
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 7.0.0
    )

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBDIR "${SOURCE_PATH}/lib64")
    else()
        set(LIBDIR "${SOURCE_PATH}/lib32")
    endif()

    file(COPY "${LIBDIR}/chartdir70.dll"  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY "${LIBDIR}/chartdir70.lib"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${LIBDIR}/chartdir70.dll"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY "${LIBDIR}/chartdir70.lib"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    set(CHARTDIR_LIB "chartdir70.lib")

elseif(VCPKG_TARGET_IS_OSX)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "https://www.advsofteng.net/chartdir_cpp_mac.tar.gz"
        FILENAME "chartdir_cpp_mac-7.0.0.tar.gz"
        SHA512 3f00a4eb7c6b7fc1ebd4856c287ca9a76ca4ce813b4203350526c7ef10c946baa3768446178b664af8e8222275f10f9ee6f5f87cf1e23f23c4a221f431864744
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 7.0.0
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.7.dylib"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${SOURCE_PATH}/lib/libchartdir.7.dylib"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    set(CHARTDIR_LIB "libchartdir.7.dylib")

elseif(VCPKG_TARGET_IS_LINUX)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "http://www.advsofteng.net/chartdir_cpp_linux_64.tar.gz"
            FILENAME "chartdir_cpp_linux_64-7.0.0.tar.gz"
            SHA512 e7e71b64b3a756b6df174758c392ab4c9310b4d265e521dccbd009eeefd46e021a74572e7212de5564725df20ddf189e1599e88a116b426f1256f7d34b0131aa
        )

    else()

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "http://www.advsofteng.net/chartdir_cpp_linux.tar.gz"
            FILENAME "chartdir_cpp_linux-7.0.0.tar.gz"
            SHA512 bf749c9821a901a7071964f22aabb606f90dc853907720a05252165d63d27aa31d10f0aa62995ab92085bb790f3830063fd8042331195b0153a9d49e8a92e871
        )

    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE_FILE}
        REF 7.0.0
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.7.0.0"  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.7.0.0"  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    set(CHARTDIR_LIB "libchartdir.so.7.0.0")

    file(COPY ${SOURCE_PATH}/lib/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

endif()

file(GLOB HEADERS "${SOURCE_PATH}/include/*.h")
file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/chartdir.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/chartdir-config.cmake @ONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
