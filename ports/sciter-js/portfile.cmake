vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(SCITER_ARCH x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(SCITER_ARCH x86)
else()
	message(FATAL_ERROR "Sciter only supports x86/x64")
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sciter-engine/sciter-js-sdk
    REF "${VERSION}"
    SHA512 a101a3188bcd4595e59fa9bd377681a12cf096180d7157d330d383be852e6e68096262d5304a2573d08453af082d915cd5001c879e70d59d70f4fc6d6d29b247
)

# install include directory
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sciter-js"
    FILES_MATCHING
    PATTERN "*.cpp"
    PATTERN "*.mm"
    PATTERN "*.h"
    PATTERN "*.hpp"
)

set(SCITER_SHARE "${CURRENT_PACKAGES_DIR}/share/sciter-js")
set(SCITER_TOOLS "${CURRENT_PACKAGES_DIR}/tools/sciter-js")
set(TOOL_PERMS FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# license
file(COPY "${SOURCE_PATH}/CHANGELOG.md" DESTINATION "${SCITER_SHARE}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# tools
if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SCITER_BIN ${SOURCE_PATH}/bin/linux/x64)

    file(INSTALL "${SOURCE_PATH}/bin/linux/packfolder" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SOURCE_PATH}/bin/linux/qjs" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SOURCE_PATH}/bin/linux/qjsc" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})

    file(INSTALL "${SCITER_BIN}/usciter" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SCITER_BIN}/inspector" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SCITER_BIN}/libsciter.so" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/sciter-sqlite.so" DESTINATION "${SCITER_TOOLS}")

    file(INSTALL "${SCITER_BIN}/libsciter.so" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SCITER_BIN}/libsciter.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

    if ("sqlite" IN_LIST FEATURES)
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.so" DESTINATION "${SCITER_TOOLS}")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.so" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

elseif(VCPKG_TARGET_IS_OSX)
    set(SCITER_BIN "${SOURCE_PATH}/bin/macosx")

    file(INSTALL "${SCITER_BIN}/packfolder" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SCITER_BIN}/qjs" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})
    file(INSTALL "${SCITER_BIN}/qjsc" DESTINATION "${SCITER_TOOLS}" ${TOOL_PERMS})

    file(INSTALL "${SCITER_BIN}/inspector.app" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/usciterjs.app" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/libsciter.dylib" DESTINATION "${SCITER_TOOLS}")

    execute_process(COMMAND sh -c "chmod +x usciterjs.app/Contents/MacOS/usciterjs" WORKING_DIRECTORY "${SCITER_TOOLS}")
    execute_process(COMMAND sh -c "chmod +x inspector.app/Contents/MacOS/inspector" WORKING_DIRECTORY "${SCITER_TOOLS}")

    if ("sqlite" IN_LIST FEATURES)
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dylib" DESTINATION "${SCITER_TOOLS}")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    if ("webview" IN_LIST FEATURES)
        file(INSTALL "${SCITER_BIN}/sciter-webview.dylib" DESTINATION "${SCITER_TOOLS}")
        file(INSTALL "${SCITER_BIN}/sciter-webview.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SCITER_BIN}/sciter-webview.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    file(INSTALL "${SCITER_BIN}/libsciter.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SCITER_BIN}/libsciter.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

elseif(VCPKG_TARGET_IS_WINDOWS)
    set(SCITER_BIN "${SOURCE_PATH}/bin/windows/${SCITER_ARCH}")

    file(INSTALL "${SOURCE_PATH}/bin/windows/packfolder.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SOURCE_PATH}/bin/windows/qjs.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SOURCE_PATH}/bin/windows/qjsc.exe" DESTINATION "${SCITER_TOOLS}")

    file(INSTALL "${SCITER_BIN}/scapp.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/usciter.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/inspector.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/window-mixin.exe" DESTINATION "${SCITER_TOOLS}")
    file(INSTALL "${SCITER_BIN}/sciter.dll" DESTINATION "${SCITER_TOOLS}")

    if ("sqlite" IN_LIST FEATURES)
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dll" DESTINATION "${SCITER_TOOLS}")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SCITER_BIN}/sciter-sqlite.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    if ("webview" IN_LIST FEATURES)
        file(INSTALL "${SCITER_BIN}/sciter-webview.dll" DESTINATION "${SCITER_TOOLS}")
        file(INSTALL "${SCITER_BIN}/sciter-webview.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SCITER_BIN}/sciter-webview.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    file(INSTALL "${SCITER_BIN}/sciter.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SCITER_BIN}/sciter.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

    message(WARNING "Sciter requires manual deployment of the correct DLL files.")
endif()
