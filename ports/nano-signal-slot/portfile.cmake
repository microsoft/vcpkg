include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NoAvailableAlias/nano-signal-slot
    REF 25aa2aa90d450d3c7550c535c7993a9e2ed0764a
    SHA512 35dc9d0d9cce116a5bcea59ab9562c87dba9f6db999807ccbef7df1fb05513eaa71132ba2996eb43f0f241288096419892ac31a400ec6cb5013438e6b670194d
    HEAD_REF master
)

file(GLOB INCLUDES ${SOURCE_PATH}/*.hpp)
file(INSTALL ${INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nano-signal-slot RENAME copyright)