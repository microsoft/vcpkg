vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF a4dbb4b1c8a3825fc304bbbad3438dbe1840feae # v5.0.2
    SHA512 25cc9002fd46856854545934f385d8578f207b1ce01802a172e49e008cdf1db0db11db7cefeef18258b99c13570af9193e83f5826613d8b0a118d7bae3f0d03f
    HEAD_REF master
)

set(staticCrt OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(staticCrt ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
)

vcpkg_install_cmake()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli" RENAME copyright)
