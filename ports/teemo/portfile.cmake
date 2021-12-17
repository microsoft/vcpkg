vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 72037259a77a618160e9a9129873c39eb888e632
    SHA512 b9b3df732b8378048405d395d297920f606bbc1c698cebe8125efab952438ee59cadf940886506e8c044e06d139532a15ac3ea2dcd48a18754ac9843bb2287a9
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TEEMO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTEEMO_STATIC:BOOL=${TEEMO_STATIC}
        -DUSE_STATIC_CRT:BOOL=${USE_STATIC_CRT}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/teemo)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/teemo)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h" "#ifdef TEEMO_STATIC" "#if $<STREQUAL:${VCPKG_LIBRARY_LINKAGE},static>")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
