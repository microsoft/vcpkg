if(VCPKG_TARGET_IS_XBOX)

    cmake_path(SET GRDKLatest "$ENV{GRDKLatest}")
    cmake_path(SET GXDKLatest "$ENV{GXDKLatest}")

    find_file(GAMEINPUT_H
      NAMES GameInput.h
      PATHS "${GRDKLatest}/gameKit/Include"
            "${GXDKLatest}/gameKit/Include"
      NO_DEFAULT_PATH
    )

    find_library(GAMEINPUT_LIB
      NAMES GameInput.lib
      PATHS "${GRDKLatest}/gameKit/Lib/amd64"
            "${GXDKLatest}/gameKit/Lib/amd64"
      NO_DEFAULT_PATH
    )

    if(NOT (GAMEINPUT_H AND GAMEINPUT_LIB))
        message(FATAL_ERROR "Ensure you have installed the Microsoft GDK with Xbox Extensions installed. See https://aka.ms/gdkx.")
    endif()

    # Output user-friendly status message for installed edition.
    if(${GXDKLatest} MATCHES ".*/([0-9][0-9])([0-9][0-9])([0-9][0-9])/.*")
    set(_months "null" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
    list(GET _months ${CMAKE_MATCH_2} month)
    set(update "")
    if(${CMAKE_MATCH_3} GREATER 0)
        set(update " Update ${CMAKE_MATCH_3}")
    endif()
    message(STATUS "Found the Microsoft GDK with Xbox Extensions (${month} 20${CMAKE_MATCH_1}${update})")
    endif()

    file(INSTALL ${GAMEINPUT_H} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL ${GAMEINPUT_LIB} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL ${GAMEINPUT_LIB} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

else()

    vcpkg_download_distfile(ARCHIVE
        URLS "https://www.nuget.org/api/v2/package/Microsoft.GameInput/${VERSION}"
        FILENAME "gameinput.${VERSION}.zip"
        SHA512 80baba86f3f89aca72b4d4fdaf0091f3b24a3a671476a0973dce23ba5b8e11d625c9647b1aceed8b2eb6ecb95ff4fb7c1845e38683cf2e757bdea7210f946955
    )

    vcpkg_extract_source_archive(
        PACKAGE_PATH
        ARCHIVE ${ARCHIVE}
        NO_REMOVE_ONE_LEVEL
    )

    file(INSTALL "${PACKAGE_PATH}/native/include/gameinput.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${PACKAGE_PATH}/native/lib/${VCPKG_TARGET_ARCHITECTURE}/gameinput.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${PACKAGE_PATH}/native/lib/${VCPKG_TARGET_ARCHITECTURE}/gameinput.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    file(INSTALL "${PACKAGE_PATH}/redist/GameInputRedist.msi" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

    vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")

endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/gameinput-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    COPYONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
