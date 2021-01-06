vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-0.10.1 # use commit from master for windows/hidapi.vcxproj
    SHA512 1
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

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/hidapi-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()
