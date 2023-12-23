if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(FB_ARCH "Win32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(FB_ARCH "x64")
endif()


# Release build

vcpkg_execute_build_process(
    COMMAND run_all.bat
        JUSTBUILD
        RELEASE
        CLIENT_ONLY
    WORKING_DIRECTORY "${SOURCE_PATH}/builds/win32"
    LOGNAME configure-${TARGET_TRIPLET}-rel
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/fbclient.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
)

file(
    INSTALL "${SOURCE_PATH}/temp/${FB_ARCH}/release/yvalve/fbclient.pdb"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
)

file(GLOB ICU_FILES_RELEASE
    "${SOURCE_PATH}/output_${FB_ARCH}_release/icu*.dll"
)
file(
    INSTALL ${ICU_FILES_RELEASE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
)

file(GLOB PLUGINS_FILES_RELEASE
    "${SOURCE_PATH}/output_${FB_ARCH}_release/plugins/*"
)
file(
    INSTALL ${PLUGINS_FILES_RELEASE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/icudt63l.dat"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_release/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)


# Debug build

vcpkg_execute_build_process(
    COMMAND run_all.bat
        JUSTBUILD
        DEBUG
        CLIENT_ONLY
    WORKING_DIRECTORY "${SOURCE_PATH}/builds/win32"
    LOGNAME configure-${TARGET_TRIPLET}-dbg
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_debug/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_debug/fbclient.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
)

file(
    INSTALL "${SOURCE_PATH}/temp/${FB_ARCH}/debug/yvalve/fbclient.pdb"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
)

file(GLOB ICU_FILES_DEBUG
    "${SOURCE_PATH}/output_${FB_ARCH}_debug/icu*.dll"
)
file(
    INSTALL ${ICU_FILES_DEBUG}
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
)

file(GLOB PLUGINS_FILES_DEBUG
    "${SOURCE_PATH}/output_${FB_ARCH}_debug/plugins/*"
)
file(
    INSTALL ${PLUGINS_FILES_DEBUG}
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_debug/icudt63l.dat"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_debug/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

file(
    INSTALL "${SOURCE_PATH}/output_${FB_ARCH}_debug/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)
