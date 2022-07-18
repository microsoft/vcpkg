# ChartDirector's DLL interface only contains primitive types, so it is CRT agnostic.
if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    message(STATUS "Note: ${PORT} only supports dynamic library linkage. Building dynamic library.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_TARGET_IS_WINDOWS)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "https://www.advsofteng.com/vcpkg/chartdir_cpp_win_7.0.0.zip"
        FILENAME "chartdir_cpp_win-7.0.0.zip"
        SHA512 e5b5d387cff693a7f5ee98c2d2df75f421129b006e4324ae30ace0cbaac58867f048868ddfacdb3224c7165c8f27219c4273f3c778be3330d39ef95260d4186b
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE_FILE}"
        REF 7.0.0
    )

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBDIR "${SOURCE_PATH}/lib64")
    else()
        set(LIBDIR "${SOURCE_PATH}/lib32")
    endif()

    file(COPY "${LIBDIR}/chartdir70.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${LIBDIR}/chartdir70.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${LIBDIR}/chartdir70.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${LIBDIR}/chartdir70.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    set(CHARTDIR_LIB "chartdir70.lib")

elseif(VCPKG_TARGET_IS_OSX)

    vcpkg_download_distfile(ARCHIVE_FILE
        URLS "https://www.advsofteng.com/vcpkg/chartdir_cpp_mac_7.0.0.tar.gz"
        FILENAME "chartdir_cpp_mac-7.0.0.tar.gz"
        SHA512 fd46ac45e8906854ededb9e30ee3ba8bdd05588e6ca7c9fdf140254ee637d32565417d799da33b23228f1ade8111fcae037eed4cf978a11d35e70ab8861214a2
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE_FILE}"
        REF 7.0.0
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.7.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${SOURCE_PATH}/lib/libchartdir.7.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    set(CHARTDIR_LIB "libchartdir.7.dylib")

elseif(VCPKG_TARGET_IS_LINUX)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "https://www.advsofteng.com/vcpkg/chartdir_cpp_linux_64_7.0.0.tar.gz"
            FILENAME "chartdir_cpp_linux_64-7.0.0.tar.gz"
            SHA512 ea2e05f28dd9647fed49feaf130d8034065067463965f144b3fae4eae482579b1ecf528dc86d1b3602887d5ca0c3b1569404489b0f4cb2300b798fed940cd467
        )

    else()

        vcpkg_download_distfile(ARCHIVE_FILE
            URLS "https://www.advsofteng.com/vcpkg/chartdir_cpp_linux_7.0.0.tar.gz"
            FILENAME "chartdir_cpp_linux-7.0.0.tar.gz"
            SHA512 54720fb431fa0fb34be3a187ec3886b0f2a7307ea52a0415fab8513117a157f64a8c0e0b01304aac1d313e4557768242e6b12002509fde2e5303d930c78c0e03
        )

    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE_FILE}"
        REF 7.0.0
    )

    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.7.0.0" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${SOURCE_PATH}/lib/libchartdir.so.7.0.0" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    set(CHARTDIR_LIB "libchartdir.so.7.0.0")

    file(COPY "${SOURCE_PATH}/lib/fonts" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

endif()

file(GLOB HEADERS "${SOURCE_PATH}/include/*.h")
file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/chartdir.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/chartdir-config.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
