include(vcpkg_common_functions)
set(PORT_VERSION 6.1.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/coolprop-${PORT_VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH ${SOURCE_PATH}
    REPO CoolProp/CoolProp
    REF v${PORT_VERSION}
    SHA512 012b994db829ee1c4e0702a964bd7d3402f378bd88d5c38b874178a3402cf39fa656b1a9e4645ad257c7184fd0bf8652e3435af7f8d41fa13aa200cd7ee7f534
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DCOOLPROP_SHARED_LIBRARY=ON
            -DCOOLPROP_STATIC_LIBRARY=OFF
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DCOOLPROP_SHARED_LIBRARY=OFF
            -DCOOLPROP_STATIC_LIBRARY=ON
    )
endif()

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/coolprop
  RENAME copyright
)
