include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message("${PORT} currently requires the following tools from the system package manager:\n    python-six\n\nThis can be installed on Ubuntu systems via apt-get install python-six python3-six (depending on your current python default interpreter)")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF v0.3.0
    SHA512 67766d226e1b900c0c37309099ecdbe987d10888ebf43f9066b21cf79f64d34e6ac30c2671a4901892f044859da4e8dbaa9fed5a49c633f73fef3bec75774050
    HEAD_REF master
)

file(READ ${SOURCE_PATH}/CMakeLists.txt OPEN62541_CMAKELISTS)
string(REPLACE
               "RUNTIME DESTINATION \${CMAKE_INSTALL_PREFIX}"
               "RUNTIME DESTINATION \${BIN_INSTALL_DIR}"
       OPEN62541_CMAKELISTS "${OPEN62541_CMAKELISTS}")
file(WRITE ${SOURCE_PATH}/CMakeLists.txt "${OPEN62541_CMAKELISTS}")

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
if(NOT EXISTS ${PYTHON3_DIR}/easy_install${EXECUTABLE_SUFFIX})
    if(NOT EXISTS ${PYTHON3_DIR}/Scripts/pip${EXECUTABLE_SUFFIX})
        vcpkg_download_distfile(GET_PIP
            URLS "https://bootstrap.pypa.io/get-pip.py"
            FILENAME "tools/python/python3/get-pip.py"
            SHA512 99520d223819708b8f6e4b839d1fa215e4e8adc7fcd0db6c25a0399cf2fa10034b35673cf450609303646d12497f301ef53b7e7cc65c78e7bce4af0c673555ad
        )
        execute_process(COMMAND ${PYTHON3_DIR}/python${EXECUTABLE_SUFFIX} ${PYTHON3_DIR}/get-pip.py)
    endif()
    execute_process(COMMAND ${PYTHON3_DIR}/Scripts/pip${EXECUTABLE_SUFFIX} install six)
else()
    execute_process(COMMAND ${PYTHON3_DIR}/easy_install${EXECUTABLE_SUFFIX} six)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/open62541/tools)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/open62541)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/open62541/LICENSE ${CURRENT_PACKAGES_DIR}/share/open62541/copyright)
