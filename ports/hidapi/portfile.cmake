vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-0.10.1
    SHA512 0479706c631775483378070ff7170542725678eabc202a5bd07436c951fd766e01743417999ac3fb2b5436c865f6ace2cfced1f210fa3a3e88c19ceb3bbe0534
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(READ "${SOURCE_PATH}/windows/hidapi.vcxproj" _contents)
    if(${VCPKG_CRT_LINKAGE} STREQUAL "dynamic")
        string(REGEX REPLACE
            "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>"
            "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>"
            _contents "${_contents}")
        string(REGEX REPLACE
            "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>"
            "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>"
            _contents "${_contents}")
    else()
        string(REGEX REPLACE
            "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>"
            "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>"
            _contents "${_contents}")
        string(REGEX REPLACE
            "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>"
            "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>"
            _contents "${_contents}")
    endif()

    if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
        string(REPLACE
            "<ConfigurationType>StaticLibrary</ConfigurationType>"
            "<ConfigurationType>DynamicLibrary</ConfigurationType>"
            _contents "${_contents}")
    else()
        string(REPLACE
            "<ConfigurationType>DynamicLibrary</ConfigurationType>"
            "<ConfigurationType>StaticLibrary</ConfigurationType>"
            _contents "${_contents}")
    endif()
    file(WRITE "${SOURCE_PATH}/windows/hidapi.vcxproj" "${_contents}")

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH windows/hidapi.vcxproj
        INCLUDES_SUBPATH hidapi ALLOW_ROOT_INCLUDES
        LICENSE_SUBPATH LICENSE-bsd.txt # use BSD license
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
    )
    vcpkg_install_make()
    file(COPY "${SOURCE_PATH}/LICENSE-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/hidapi/copyright")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/hidapi-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
