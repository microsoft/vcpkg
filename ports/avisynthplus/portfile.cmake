vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_LIBRARY_LINKAGE "static" ON_TARGET "UWP")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviSynth/AviSynthPlus
    REF v3.6.1
    SHA512 7104c334769aacf3b1c14491c2e0cdd6586d6ea68dae7d10e7955ac56c6277fe4ae189d30ebd161baeda80e65e80fc49d4b2aed476272dd1aa235e7c8f0209d9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_PLUGINS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/distrib/gpl.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
