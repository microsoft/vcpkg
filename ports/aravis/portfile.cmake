if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
message(STATUS "${PORT} currently requires the following tools from the system package manager:
    glib-2.0
    libxml2
This can be installed on Ubuntu systems via apt-get install libglib2.0-dev libxml2-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AravisProject/aravis
    REF e49cfe86dfa5e526de1047db876315340cefce2b
    SHA512 1b93197031f1a4912911c320e88eda67f7c08db1570c22213f5f2ec41f17e17b6f04c513b8990871e07864137da3cf725389da2aceca4035303560f472ea2a83
    HEAD_REF master
)

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
