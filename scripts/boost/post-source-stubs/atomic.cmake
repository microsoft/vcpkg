vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2"
    "project.load [ path.join [ path.make $(here:D) ] ../../config/checks/architecture ]"
    "project.load [ path.join [ path.make $(here:D) ] ../config/checks/architecture ]"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
#Make sure to keep this line when updating boost.
file(INSTALL "${SOURCE_PATH}/config/has_synchronization_lib.cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost-atomic")