include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/ade
    REF v0.1.1e
    SHA512 6271b3a6d23b155757a47b21f70cb169b0469501bd1a7c99aa91a76117387840e02b4c70dc4069b7c50408f760b9a7ea77527a30b4691048a1ee55dd94988dd5
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/ade/adeTargets-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/ade/)

file(READ ${CURRENT_PACKAGES_DIR}/share/ade/adeTargets-debug.cmake ADE_TARGET_DEBUG)
string(REPLACE "/lib/"
               "/debug/lib/" ADE_TARGET_DEBUG "${ADE_TARGET_DEBUG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/ade/adeTargets-debug.cmake "${ADE_TARGET_DEBUG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ade RENAME copyright)
