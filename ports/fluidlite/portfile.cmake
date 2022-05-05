if(EXISTS "${CURRENT_INSTALLED_DIR}/include/fluidsynth/settings.h")
  message(FATAL_ERROR "Can't build fluidlite if fluidsynth is installed. Please remove fluidsynth, and try to install fluidlite again if you need it.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO divideconcept/FluidLite
    REF fdd05bad03cdb24d1f78b5fe3453842890c1b0e8
    SHA512 8118bec2cb5ee48b8064ed2111610f1917ee8e6f1dc213121b2311d056da21d7f618ef50735e7653d2cccf1e96652f3ccf026101fccb9863448008918add53e0
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

vcpkg_fixup_pkgconfig()
