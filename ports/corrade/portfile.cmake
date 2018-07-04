include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/corrade
    REF v2018.04
    SHA512 be14f0cb76c904a37f962af16b331407ec6a1f7a31245c7221f41fcbce2749a1ad67057d451736814e357eaa59e015f16996bdba819f69a1dd0f3d5a3cad34a4
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

# Handle features
set(_COMPONENT_FLAGS "")
foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Turn "-DWITH_*=" ON or OFF depending on whether the feature
    # is in the list.
    if(_feature IN_LIST FEATURES)
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=ON")
    else()
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=OFF")
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
        ${_COMPONENT_FLAGS}
)

vcpkg_install_cmake()

# Debug includes and share are the same as release
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Install tools
if("utility" IN_LIST FEATURES)
    file(GLOB EXES
        ${CURRENT_PACKAGES_DIR}/bin/corrade-rc
        ${CURRENT_PACKAGES_DIR}/bin/corrade-rc.exe
    )

    # Drop a copy of tools
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/corrade)

    # Tools require dlls
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/corrade)

    file(GLOB TO_REMOVE
        ${CURRENT_PACKAGES_DIR}/bin/corrade-rc*
        ${CURRENT_PACKAGES_DIR}/debug/bin/corrade-rc*)
    file(REMOVE ${TO_REMOVE})
endif()

# Ensure no empty folders are left behind
if(NOT FEATURES)
    # No features, no binaries (only Corrade.h).
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/debug)
    # debug is completely empty, as include and share
    # have already been removed.

elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # No dlls
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/corrade)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/share/corrade/COPYING
    ${CURRENT_PACKAGES_DIR}/share/corrade/copyright)

vcpkg_copy_pdbs()
