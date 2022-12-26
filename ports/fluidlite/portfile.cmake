if(EXISTS "${CURRENT_PACKAGES_DIR}/share/fluidsynth/copyright")
    message(FATAL_ERROR "Can't build fluidlite if fluidsynth is installed. Please remove fluidsynth, and try to install fluidlite again if you need it.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUIDLITE_BUILD_STATIC=${FLUIDLITE_BUILD_STATIC}
        -DFLUIDLITE_BUILD_SHARED=${FLUIDLITE_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
