include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qtdeclarative 0caddcfee36cbf52bacd3a400d304511255715e2b5a58c1621ca8120610427c57511785457a9e7fa55975b86e7924a3cffddeb7e2e8e6622af85b7ebac35dd20)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-declarative/plugins/platforminputcontexts)

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
	set(qt5decpath ${CURRENT_PACKAGES_DIR}/share/qt5/debug/mkspecs/modules/qt_lib_qmldevtools_private.pri)
	file(READ "${qt5decpath}" _contents)
	string(REPLACE [[QT.qmldevtools_private.libs = $$QT_MODULE_HOST_LIB_BASE]] [[QT.qmldevtools_private.libs = $$QT_MODULE_LIB_BASE]]  _contents "${_contents}")
	file(WRITE "${qt5decpath}" "${_contents}")
endif()

# Copy qt5-declarative tools
# This is a temporary workaround and hope to fix and remove it after the version update.
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if (EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5-declarative/)
        file(RENAME ${CURRENT_PACKAGES_DIR}/tools/qt5-declarative/ ${CURRENT_PACKAGES_DIR}/tools/qt5/)
    endif()
    if (EXISTS ${CURRENT_PACKAGES_DIR}/lib/libQt5QmlDevTools.a)
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/libQt5QmlDevTools.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    endif()
endif()