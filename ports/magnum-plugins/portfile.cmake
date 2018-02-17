include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-plugins
    REF v2018.02
    SHA512 650d3ec26b3c72aa98ffa242b072e382445de49d4849042faf5dac800d5e4cce223cac3fa1cc079fcb230632730af1d90ac7d347d152a1f31d224732499e96b4
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/001-tools-path.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC 1)
else()
    set(BUILD_STATIC 0)
endif()

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
        ${_COMPONENT_FLAGS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_install_cmake()

# Debug includes and share are the same as release
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

# Clean up empty directories
if(NOT FEATURES)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/debug)
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
   # move plugin libs to conventional place
   file(GLOB_RECURSE LIB_TO_MOVE ${CURRENT_PACKAGES_DIR}/lib/magnum/*)
   file(COPY ${LIB_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/magnum)
   file(GLOB_RECURSE LIB_TO_MOVE_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/magnum/*)
   file(COPY ${LIB_TO_MOVE_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/magnum)
else()
   # remove headers and libs for plugins
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
   # hint vcpkg
   set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
   set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/MagnumPlugins)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/magnum)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/magnum-d)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/magnum-plugins)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/COPYING ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/copyright)

vcpkg_copy_pdbs()
