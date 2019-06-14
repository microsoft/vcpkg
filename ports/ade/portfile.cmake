include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/ade
    REF v0.1.1d
    SHA512 c493cb57e59ba859ca0cbf5d48bae4233f22104dfb4a96864d07e9422bb700c27af2d53a602f2230d68b7bcc598920d0652c3d9fdf8fad94a7e5b4d21664a44e
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
