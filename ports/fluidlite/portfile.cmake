if(EXISTS "${CURRENT_INSTALLED_DIR}/include/fluidsynth/settings.h")
  message(FATAL_ERROR "Can't build fluidlite if fluidsynth is installed. Please remove fluidsynth, and try to install fluidlite again if you need it.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO divideconcept/FluidLite
    REF 1cf5c3ab61ea0a3abfbe13ac0692a056e8c0d535
    SHA512 785911d9b414b744d8f09492ad713d63344d4ef36b4a9e747b78172c94373b4949422d7c1b1ae42af6b5305f0df5d08cf81e9c443f85c93086131f0f9c029007
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" FLUIDLITE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" FLUIDLITE_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFLUIDLITE_BUILD_STATIC=${FLUIDLITE_BUILD_STATIC}
        -DFLUIDLITE_BUILD_SHARED=${FLUIDLITE_BUILD_SHARED}
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)

vcpkg_install_cmake()

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
