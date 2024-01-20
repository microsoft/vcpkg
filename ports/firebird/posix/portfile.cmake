# Firebird libraries are already relocatable and this causes problems with their runpaths.
set(VCPKG_FIXUP_ELF_RPATH OFF)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    AUTOCONFIG
    OPTIONS
        --enable-client-only
        --enable-binreloc
        --with-builtin-tomcrypt
        --with-builtin-tommath
        --with-termlib=:libncurses.a
        --with-atomiclib=:libatomic.a
        --with-plugins=plugins/${PORT}
        --with-fbmsg=share/${PORT}
        --with-tzdata=share/${PORT}/tzdata
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

file(
    INSTALL "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
    USE_SOURCE_PERMISSIONS
    PATTERN "libtom*" EXCLUDE
)

file(GLOB EXT_LIBS_RELEASE
    "${SOURCE_COPY_REL_PATH}/extern/libtomcrypt/.libs/libtomcrypt.so*"
    "${SOURCE_COPY_REL_PATH}/extern/libtommath/.libs/libtommath.so*"
)
file(
    INSTALL ${EXT_LIBS_RELEASE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    USE_SOURCE_PERMISSIONS
)

file(GLOB PLUGINS_FILES_RELEASE
    "${SOURCE_COPY_REL_PATH}/gen/Release/firebird/plugins/*"
)
file(
    INSTALL ${PLUGINS_FILES_RELEASE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}"
    USE_SOURCE_PERMISSIONS
)

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

file(
    INSTALL "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug"
    USE_SOURCE_PERMISSIONS
    PATTERN "libtom*" EXCLUDE
)

file(GLOB EXT_LIBS_DEBUG
    "${SOURCE_COPY_DBG_PATH}/extern/libtomcrypt/.libs/libtomcrypt.so*"
    "${SOURCE_COPY_DBG_PATH}/extern/libtommath/.libs/libtommath.so*"
)
file(
    INSTALL ${EXT_LIBS_DEBUG}
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
    USE_SOURCE_PERMISSIONS
)

file(GLOB PLUGINS_FILES_DEBUG
    "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/plugins/*"
)
file(
    INSTALL ${PLUGINS_FILES_DEBUG}
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}"
    USE_SOURCE_PERMISSIONS
)

file(
    INSTALL "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/firebird.msg"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

file(
    INSTALL "${SOURCE_COPY_DBG_PATH}/gen/Debug/firebird/tzdata"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)
