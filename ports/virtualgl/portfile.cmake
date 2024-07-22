vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VirtualGL/virtualgl
    REF "${VERSION}"
    SHA512 4668ebfbfe663d3cf66468b120ecf46da161cbce3b793dbeaea9ace50d19d8d3edcdc84ef31d87b27903c1c8a6648ae0419c796960928f1421a90171a5db7d43
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "opencl"    VGL_FAKEOPENCL
        "xcb"       VGL_FAKEXCB
        "xv"        VGL_USEXV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DTJPEG_INCLUDE_DIR=${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/include"
        ${FEATURE_OPTIONS}
)


vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES
    cpustat
    eglinfo
    eglxinfo
    eglxspheres64
    glxinfo
    glreadtest
    glxspheres64
    nettest
    tcbench
    vglclient
    vglconfig
    vglconnect
    vglgenkey
    vgllogin
    vglrun
    .vglrun.vars64
    vglserver_config
    AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
