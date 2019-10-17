vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AravisProject/aravis
    REF e49cfe86dfa5e526de1047db876315340cefce2b
    SHA512 1b93197031f1a4912911c320e88eda67f7c08db1570c22213f5f2ec41f17e17b6f04c513b8990871e07864137da3cf725389da2aceca4035303560f472ea2a83
    HEAD_REF master
    PATCHES
        allow_better_dependencies_search.patch
)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(CMAKE_HOST_WIN32)
    if(NOT EXISTS ${PYTHON3_DIR}/easy_install${EXECUTABLE_SUFFIX})
        if(NOT EXISTS ${PYTHON3_DIR}/Scripts/pip${EXECUTABLE_SUFFIX})
            get_filename_component(PYTHON3_DIR_NAME "${PYTHON3_DIR}" NAME)
            vcpkg_download_distfile(GET_PIP
                URLS "https://bootstrap.pypa.io/3.3/get-pip.py"
                FILENAME "tools/python/${PYTHON3_DIR_NAME}/get-pip.py"
                SHA512 92e68525830bb23955a31cb19ebc3021ef16b6337eab83d5db2961b791283d2867207545faf83635f6027f2f7b7f8fee2c85f2cfd8e8267df25406474571c741
            )
            execute_process(COMMAND ${PYTHON3_DIR}/python${EXECUTABLE_SUFFIX} ${GET_PIP})
        endif()
        execute_process(COMMAND ${PYTHON3_DIR}/Scripts/pip${EXECUTABLE_SUFFIX} install python-gettext --user)
    else()
        execute_process(COMMAND ${PYTHON3_DIR}/easy_install${EXECUTABLE_SUFFIX} python-gettext)
    endif()
endif()

vcpkg_find_acquire_program(GETTEXT)
get_filename_component(GETTEXT_DIR "${GETTEXT}" DIRECTORY)
vcpkg_add_to_path("${GETTEXT_DIR}")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/glib")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dviewer=false
        -Dgst-plugin=false
        -Dpacket-socket=false
        -Dusb=false
        -Dfast-heartbeat=false
        -Ddocumentation=false
        -Dintrospection=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

if(CMAKE_HOST_WIN32)
  set(EXECUTABLE_SUFFIX ".exe")
else()
  set(EXECUTABLE_SUFFIX "")
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/arv-fake-gv-camera-0.8${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/arv-tool-0.8${EXECUTABLE_SUFFIX})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/arv-fake-gv-camera-0.8${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/arv-fake-gv-camera-0.8${EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/arv-tool-0.8${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/arv-tool-0.8${EXECUTABLE_SUFFIX})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
