vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntop/PF_RING
    REF "${VERSION}"
    SHA512 de86fb2ead8af63a3b73026225ac2dba9ae97c90d0925e30c63ed75f1d1f7f057b6ab586b06dd24fdbbfdce694048b72bbdd35fc4de0c22508701a6c3ee7c7a2
    HEAD_REF dev
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
endif()


message(STATUS "Configuring ${TARGET_TRIPLET}-rel")

vcpkg_execute_required_process(
    COMMAND "./configure"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/userland/lib"
    LOGNAME config-${TARGET_TRIPLET}-rel
)

message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND make
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/userland/lib"
    LOGNAME build-${TARGET_TRIPLET}-rel
)

message(STATUS "Installing ${TARGET_TRIPLET}-rel")
file(GLOB LIB_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/userland/lib/libs/libpfring*.a")
file(INSTALL ${LIB_FILE} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/userland/lib/libpfring.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(GLOB HEADER_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/userland/lib/pfring*.h")
file(INSTALL ${HEADER_FILE} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

if (NOT VCPKG_BUILD_TYPE)
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")

    vcpkg_execute_required_process(
        COMMAND "./configure"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/userland/lib"
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND make
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/userland/lib"
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
    
    message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
    file(GLOB LIB_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/userland/lib/libs/libpfring*.a")
    file(INSTALL ${LIB_FILE} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/userland/lib/libpfring.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

#Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
