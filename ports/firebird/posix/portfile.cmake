# In Linux, we adjust rpaths to be more precise than what vcpkg does by default.
set(VCPKG_FIXUP_ELF_RPATH OFF)
#set(VCPKG_FIXUP_MACHO_RPATH OFF)

if(NOT VCPKG_TARGET_IS_OSX)
vcpkg_find_acquire_program(PATCHELF)
endif()

set(FIREBIRD_CONFIGURE_OPTIONS
    --enable-client-only
    --enable-binreloc
    --with-plugins=plugins/${PORT}
    --with-fbmsg=share/${PORT}
    --with-tzdata=share/${PORT}/tzdata
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND FIREBIRD_CONFIGURE_OPTIONS
        --enable-fbclient-static
    )
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    AUTOCONFIG
    OPTIONS
        ${FIREBIRD_CONFIGURE_OPTIONS}
    OPTIONS_DEBUG
        --enable-developer
)

vcpkg_build_make()


# Release build

set(SOURCE_COPY_REL_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

file(
    INSTALL "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB FIREBIRD_RELEASE_LIBS
        "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/lib/*"
    )
else()
    file(GLOB FIREBIRD_RELEASE_LIBS
        "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/lib/*.a"
    )
endif()

file(
    INSTALL ${FIREBIRD_RELEASE_LIBS}
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    USE_SOURCE_PERMISSIONS
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB PLUGINS_FILES_RELEASE
        "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/plugins/*"
    )

    if(NOT VCPKG_TARGET_IS_OSX)
        foreach(plugin ${PLUGINS_FILES_RELEASE})
            execute_process(
                COMMAND "${PATCHELF}" --set-rpath "$ORIGIN/../../lib" ${plugin}
            )
        endforeach()
    endif()

    file(
        INSTALL ${PLUGINS_FILES_RELEASE}
        DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
endif()

file(
    INSTALL "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(
    INSTALL "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)


# Debug build

set(SOURCE_COPY_DBG_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB FIREBIRD_DEBUG_LIBS
        "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/lib/*"
    )
else()
    file(GLOB FIREBIRD_DEBUG_LIBS
        "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/lib/*.a"
    )
endif()

file(
    INSTALL ${FIREBIRD_DEBUG_LIBS}
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
    USE_SOURCE_PERMISSIONS
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB PLUGINS_FILES_DEBUG
        "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/plugins/*"
    )

    if(NOT VCPKG_TARGET_IS_OSX)
        foreach(plugin ${PLUGINS_FILES_DEBUG})
            execute_process(
                COMMAND "${PATCHELF}" --set-rpath "$ORIGIN/../../lib" ${plugin}
            )
        endforeach()
    endif()

    file(
        INSTALL ${PLUGINS_FILES_DEBUG}
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
endif()

file(
    INSTALL "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

file(
    INSTALL "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)
