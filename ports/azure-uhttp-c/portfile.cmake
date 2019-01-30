include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF e459385a811ce075f42aa7202db96ba1d1f55ac1
        SHA512 b96382184893b49f30ad75d4c19eeb48f7a7823e9d48f2896ee4760be20f2f5b5ee3e78e39f10ae26363165360e5871c3ba82aa9edf3943b9f0ef9c0e3036ea6
        HEAD_REF public-preview
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF 647ec7cc75961cd7ff7cbb7eca30e1de819802ed
        SHA512 1768ea978ab7fa328b74444573c3d1eb2a5fae1e36dbe1dcc186df3e2ab2a0a3b1ba8a434934462184582525b3a1850fc04ca2927f95f0df0ae483f8a1673e30
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/c-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/uhttp)

# Fix relative paths that vcpkg_fixup_cmake_targets didn't pick up
set(TARGETS_CMAKE ${CURRENT_PACKAGES_DIR}/share/uhttp/uhttpTargets.cmake)
file(READ ${TARGETS_CMAKE} _contents)
string(REGEX REPLACE
    "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents "${_contents}")
file(WRITE ${TARGETS_CMAKE} "${_contents}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uhttp-c/copyright COPYONLY)

vcpkg_copy_pdbs()
