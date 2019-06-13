include(vcpkg_common_functions)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenMAMA/OpenMAMA
    REF OpenMAMA-6.2.3-release
    SHA512 2d641a34f4301f8aa0a33cc6c1172e2d3215792955a56f13858d758cedfea1c2ec3ae466112f06f9be7a67d80569f12238eca98008e6623558183b08dcd954c0
    HEAD_REF next
)

set(OPENMAMA_TARGET_ARCH ${TRIPLET_SYSTEM_ARCH})
if(${TRIPLET_SYSTEM_ARCH} STREQUAL x64)
    set(OPENMAMA_TARGET_ARCH x86_64)
endif()

# Clean from any previous builds
vcpkg_execute_required_process(
    COMMAND ${SCONS}
        -c
        target_arch=${OPENMAMA_TARGET_ARCH}
        libevent_home=${CURRENT_INSTALLED_DIR}
        apr_home=${CURRENT_INSTALLED_DIR}
        qpid_home=${CURRENT_INSTALLED_DIR}
        vcpkg_build=y
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME clean-${TARGET_TRIPLET}.log
)

# This build
vcpkg_execute_required_process(
    COMMAND ${SCONS}
        with_unittest=False
        with_examples=False
        product=mamda
        lex=${FLEX}
        middleware=qpid
        buildtype=dynamic,dynamic-debug
        prefix=\#install
        with_dependency_runtimes=False
        target_arch=${OPENMAMA_TARGET_ARCH}
        libevent_home=${CURRENT_INSTALLED_DIR}
        apr_home=${CURRENT_INSTALLED_DIR}
        qpid_home=${CURRENT_INSTALLED_DIR}
        vcpkg_build=y
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}.log
)

# Remove dependency files which build system creates for convenience
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic/libapr-1.dll)
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic/libapr-1.pdb)
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic-debug/libapr-1.dll)
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic-debug/libapr-1.pdb)
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic/qpid-proton.dll)
file(REMOVE ${SOURCE_PATH}/install/bin/dynamic-debug/qpid-protond.dll)

# Custom install target - the build system doesn't really
# do prefixes properly and it has a different directory
# structure than vcpkg expects so reorganizing here
file(COPY ${SOURCE_PATH}/install/include
     DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${SOURCE_PATH}/install/lib/dynamic/
     DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/install/lib/dynamic-debug/
     DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/install/bin/dynamic/
     DESTINATION ${CURRENT_PACKAGES_DIR}/bin
     FILES_MATCHING PATTERN "*.dll")
file(COPY ${SOURCE_PATH}/install/bin/dynamic-debug/
     DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
     FILES_MATCHING PATTERN "*.dll")

# Copy across license files and copyright
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/openmama)
file(COPY ${SOURCE_PATH}/install/LICENSE.md
          ${SOURCE_PATH}/install/LICENSE-3RD-PARTY.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmama/)
file(COPY ${SOURCE_PATH}/install/LICENSE.md
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmama/copyright)

vcpkg_copy_pdbs()
