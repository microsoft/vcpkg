vcpkg_fail_port_install(ON_TARGET "linux" "osx" "uwp" ON_ARCH "arm")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO portmedia
    FILENAME "portmedia-code-r234.zip"
    SHA512 cbc332d89bc465450b38245a83cc300dfd2e1e6de7c62284edf754ff4d8a9aa3dc49a395dcee535ed9688befb019186fa87fd6d8a3698898c2acbf3e6b7a0794
)

# Alter path to main portmidi root
set(SOURCE_PATH "${SOURCE_PATH}/portmidi/trunk")

# Mark portmidi-static as static, disable pmjni library depending on the Java SDK

file(READ "${SOURCE_PATH}/pm_common/CMakeLists.txt" PM_CMAKE)
string(REPLACE "add_library(portmidi-static \${LIBSRC})" "add_library(portmidi-static STATIC \${LIBSRC})" PM_CMAKE "${PM_CMAKE}")
string(REPLACE "add_library(pmjni SHARED \${JNISRC})" "# Removed pmjni" PM_CMAKE "${PM_CMAKE}")
string(REPLACE "target_link_libraries(pmjni \${JNI_EXTRA_LIBS})" "# Removed pmjni" PM_CMAKE "${PM_CMAKE}")
string(REPLACE "set_target_properties(pmjni PROPERTIES EXECUTABLE_EXTENSION \"jnilib\")" "# Removed pmjni" PM_CMAKE "${PM_CMAKE}")
file(WRITE "${SOURCE_PATH}/pm_common/CMakeLists.txt" "${PM_CMAKE}")

# Run cmake configure step
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DJAVA_INCLUDE_PATH=
        -DJAVA_INCLUDE_PATH2=
        -DJAVA_JVM_LIBRARY=
)

# Run cmake build step, nothing is installed on Windows
vcpkg_build_cmake()

file(INSTALL ${SOURCE_PATH}/pm_common/portmidi.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/porttime/porttime.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/portmidi_s.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/portmidi_s.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
else()
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/portmidi.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/portmidi.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/portmidi.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/portmidi.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portmidi RENAME copyright)
