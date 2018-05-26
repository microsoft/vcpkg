include(vcpkg_common_functions)
set(PORT_COMMIT 882aec454b2bc3d5323b8691736ff09c288f4ed6)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/REFPROP-headers
    REF ${PORT_COMMIT}
    SHA512 23ee3df4ffe21b2d790efa27a1b8ea5fa4fce0a274d78e493a2d71043670420e19216f925d23d04f6139ca084a21b97028bd2547f3dbd00ffbb33d0c0bbfece5
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/REFPROP_lib.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/refprop-headers
  RENAME copyright
)
