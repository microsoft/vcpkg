vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Azure-Kinect-Sensor-SDK
    REF 17b644560ce7b4ee7dd921dfff0ae811aa54ede6 #v1.4.0-alpha.0
    SHA512 2746eebe5ef66c4b9d2215b6883723fca66dab77d405c662cc2af9364dc7fcd76aade396d23427db5797e0a534764eb2398890930ff3c792d0df8a681ce31462
    HEAD_REF master
    PATCHES
        fix-builds.patch
        disable-c4275.patch
        fix-dependency-imgui.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    docs K4A_BUILD_DOCS
    tool BUILD_TOOLS
)

# .rc file needs windows.h, so do not use PREFER_NINJA here
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
    -DK4A_SOURCE_LINK=OFF
    -DK4A_MTE_VERSION=ON
    -DBUILD_EXAMPLES=OFF
    -DWITH_TEST=OFF
    -DIMGUI_EXTERNAL_PATH=${CURRENT_INSTALLED_DIR}/include/bindings
)

vcpkg_install_cmake()

# Avoid deleting debug/lib/cmake when fixing the first cmake
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/k4a TARGET_PATH share/k4a)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/k4arecord TARGET_PATH share/k4arecord)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if ("tool" IN_LIST FEATURES)
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        file(GLOB AZURE_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        file(COPY ${AZURE_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE ${AZURE_TOOLS})
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(GLOB AZURE_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        file(REMOVE ${AZURE_TOOLS})
    endif()
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)