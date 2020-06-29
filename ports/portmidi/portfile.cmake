vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO portmedia/portmidi
    REF 217
    FILENAME "portmidi-src-217.zip"
    SHA512 d08d4d57429d26d292b5fe6868b7c7a32f2f1d2428f6695cd403a697e2d91629bd4380242ab2720e8f21c895bb75cb56b709fb663a20e8e623120e50bfc5d90b
)

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
