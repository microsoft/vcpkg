set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aui-framework/aui
    REF "v${VERSION}"
    SHA512 decac6cebb6003791896e8d7a9fd7334351aa30205eac787cdbb51d1da657cda140178e0b8f5d236b42a4c1f37633141fb869784e5fc5c9718b5396e077afe7d
    HEAD_REF master
    PATCHES
        debundle.patch
        disable-tests.patch
        fix-fmt12.patch
        fix-glm.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/aui-config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")
set(ADDITIONAL_CMAKE_ARGS "")

if (NOT(VCPKG_TARGET_IS_WINDOWS))
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ADDITIONAL_CMAKE_ARGS "${ADDITIONAL_CMAKE_ARGS} -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF
        -DAUIB_NO_PRECOMPILED=TRUE
        -DAUIB_DISABLE=ON
        ${ADDITIONAL_CMAKE_ARGS}
)

vcpkg_cmake_install()

# Remove empty folders
function(_aui_prune_empty_dirs _root)
    file(GLOB _aui_children "${_root}/*")
    foreach(_aui_child IN LISTS _aui_children)
        if(IS_DIRECTORY "${_aui_child}")
            _aui_prune_empty_dirs("${_aui_child}")
            file(GLOB _aui_grandchildren "${_aui_child}/*")
            if(NOT _aui_grandchildren)
                file(REMOVE_RECURSE "${_aui_child}")
            endif()
        endif()
    endforeach()
endfunction()
_aui_prune_empty_dirs("${CURRENT_PACKAGES_DIR}")

# aui installs its cmake config to the package root; move to share/aui/ for vcpkg_cmake_config_fixup
if(EXISTS "${CURRENT_PACKAGES_DIR}/aui-config.cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/aui-config.cmake" "${CURRENT_PACKAGES_DIR}/share/aui/aui-config.cmake")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/aui-config.cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/aui-config.cmake" "${CURRENT_PACKAGES_DIR}/debug/share/aui/aui-config.cmake")
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME "${PORT}")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/aui")
file(COPY "${CURRENT_PACKAGES_DIR}/share/aui/aui-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/aui")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
