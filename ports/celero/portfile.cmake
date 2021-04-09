vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/Celero
    REF 6208b63dcd4baeea6817d3e84f79fb04ad99c720 #2.8.2
    SHA512 13a486dafba394cc3e072292008d00e8a3e1b12b4fe7c82cf2ce43b3d24629d08b5762494c19da0a12b186a70114cba101553ed1b4cea90d090514307b06dec8
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CELERO_COMPILE_DYNAMIC_LIBRARIES)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DCELERO_ENABLE_EXPERIMENTS=OFF
        -DCELERO_ENABLE_TESTS=OFF
        -DCELERO_RUN_EXAMPLE_ON_BUILD=OFF
        -DCELERO_COMPILE_DYNAMIC_LIBRARIES=${CELERO_COMPILE_DYNAMIC_LIBRARIES}
        -DCELERO_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/celero/Export.h "ifdef CELERO_STATIC" "if 1")
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/celero/celero-target.cmake ${CURRENT_PACKAGES_DIR}/share/celero/celero-config.cmake)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
