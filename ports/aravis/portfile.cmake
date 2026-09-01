vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AravisProject/aravis
    REF "${VERSION}"
    SHA512 5c9b8ad5d2a4da9f0b31e99a4f817450f5c498507e8e4a5f2b3af2f3976eecbdabbea2112d6039aba3c077a3f4259c6ccc8e6f2d8d787938f139a221cacb4dec
    HEAD_REF main
)

set(OPTIONS "")
set(OPTIONS_RELEASE "")
if("usb" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dusb=enabled)
else()
    list(APPEND OPTIONS -Dusb=disabled)
endif()
if("packet-socket" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dpacket-socket=enabled)
else()
    list(APPEND OPTIONS -Dpacket-socket=disabled)
endif()
if("fast-heartbeat" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfast-heartbeat=true)
else()
    list(APPEND OPTIONS -Dfast-heartbeat=false)
endif()
if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS_RELEASE -Dintrospection=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH
        "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dviewer=disabled
        -Dgst-plugin=disabled
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
        "glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'"
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    AUTO_CLEAN
    TOOL_NAMES
        arv-camera-test-0.8
        arv-fake-gv-camera-0.8
        arv-test-0.8
        arv-tool-0.8
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
