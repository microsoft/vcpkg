vcpkg_fail_port_install(ON_TARGET "uwp" ON_ARCH "arm")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO portmedia
    FILENAME "portmedia-code-r234.zip"
    SHA512 cbc332d89bc465450b38245a83cc300dfd2e1e6de7c62284edf754ff4d8a9aa3dc49a395dcee535ed9688befb019186fa87fd6d8a3698898c2acbf3e6b7a0794
    PATCHES
        fix-build-install.patch
        add-feature-options.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/portmidi/trunk"
    OPTIONS
        -DJAVA_SUPPORT=OFF
        -DJAVA_INCLUDE_PATH=
        -DJAVA_INCLUDE_PATH2=
        -DJAVA_JVM_LIBRARY=
    MAYBE_UNUSED_VARIABLES
        JAVA_INCLUDE_PATH
        JAVA_INCLUDE_PATH2
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/portmidi.h"
        "#elif defined _PM_USEDLL" "#elif 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/portmidi/trunk/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
