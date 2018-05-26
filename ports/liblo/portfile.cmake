include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF 0.29
    SHA512 45648f2b2280e056b045dc0f08491baa7c154a983af95cf79438ac8fafd8f03a44c337a4beb0e01dce1f4d7352a03dc9088244d8db77dcdbfa6e39874dd6250f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DTHREADING=1
)

vcpkg_install_cmake()

# Install needed files into package directory
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/liblo)

file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/liblo)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/debug/bin/oscdump.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblo RENAME copyright)
