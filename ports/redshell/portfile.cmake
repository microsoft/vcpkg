include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/redshell)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Innervate/red-shell-cpp
    REF 1.0.0
    SHA512 00c79a09e92131e4ee0f46b14a2280bdb4e8c5970876dba99e8edd2294813f1b602eb0c9c8e24c9fd363a5c276dfa3daaf71f6ba2774842a8b565c803b3ff08c
    HEAD_REF master
)

# Header .h
file(COPY
    "${SOURCE_PATH}/include/RedShell.h"
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redshell
)

# Debug .lib
file(COPY
    "${SOURCE_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/debug/RedShell.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

# Release .lib
file(COPY
    "${SOURCE_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/RedShell.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

# Debug .dll
file(COPY
    "${SOURCE_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/debug/RedShell.dll"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)

# Release .dll
file(COPY
    "${SOURCE_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/RedShell.dll"
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)

# Copyright
file(COPY
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/redshell/copyright
)
