if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(FB_ARCH_OUT "Win32")
    set(FB_PROCESSOR_ARCHITECTURE "x86")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(FB_ARCH_OUT "x64")
    set(FB_PROCESSOR_ARCHITECTURE "AMD64")
endif()


# Release build

vcpkg_execute_build_process(
    COMMAND ${CMAKE_COMMAND} -E env
        "FB_PROCESSOR_ARCHITECTURE=${FB_PROCESSOR_ARCHITECTURE}"
        run_all.bat
        JUSTBUILD
        RELEASE
        CLIENT_ONLY
        ENABLE_FBCLIENT_STATIC=TRUE
    WORKING_DIRECTORY "${SOURCE_PATH}/builds/win32"
    LOGNAME configure-${TARGET_TRIPLET}-rel
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/lib/fbclient_ms.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )

    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/fbclient.dll"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    )

    file(
        INSTALL "${SOURCE_PATH}/temp/${FB_ARCH_OUT}/release/yvalve/fbclient.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    )

    file(GLOB PLUGINS_FILES_RELEASE
        "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/plugins/*"
    )
    file(
        INSTALL ${PLUGINS_FILES_RELEASE}
        DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}"
    )
else()
    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/lib/fbclient_static_ms.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )
endif()

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_release/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)


# Debug build

vcpkg_execute_build_process(
    COMMAND ${CMAKE_COMMAND} -E env
        "FB_PROCESSOR_ARCHITECTURE=${FB_PROCESSOR_ARCHITECTURE}"
        run_all.bat
        JUSTBUILD
        DEBUG
        CLIENT_ONLY
        ENABLE_FBCLIENT_STATIC=TRUE
    WORKING_DIRECTORY "${SOURCE_PATH}/builds/win32"
    LOGNAME configure-${TARGET_TRIPLET}-dbg
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/lib/fbclient_ms.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
    )

    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/fbclient.dll"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
    )

    file(
        INSTALL "${SOURCE_PATH}/temp/${FB_ARCH_OUT}/debug/yvalve/fbclient.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
    )

    file(GLOB PLUGINS_FILES_DEBUG
        "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/plugins/*"
    )
    file(
        INSTALL ${PLUGINS_FILES_DEBUG}
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}"
    )
else()
    file(
        INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/lib/fbclient_static_ms.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
    )
endif()

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH_OUT}_debug/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)
