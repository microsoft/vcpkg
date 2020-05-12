include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF fc677b81951d8facc99bab6b4f0060b5d89e2e15 # use commit from master for windows/hidapi.vcxproj
    SHA512 8a779c1d4fe83e264046f3193a5cefe2d9765dcde30628767838180b3dec2bdd25c9c1ec9a96b3a7edaf00df7662b4d658f2b57bda67cebc7d7cb4e737cb1f88
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(TRIPLET_SYSTEM_ARCH MATCHES "arm")
        message(FATAL_ERROR "ARM builds are currently not supported!")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
        message(FATAL_ERROR "UWP builds are currently not supported!")
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH windows/hidapi.sln
        INCLUDES_SUBPATH hidapi ALLOW_ROOT_INCLUDES
        LICENSE_SUBPATH LICENSE-bsd.txt # use BSD license
    )

    file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/hidapi-config.cmake
        DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
else()
    message(FATAL_ERROR "Non-Windows builds are currently not supported!")
endif()
