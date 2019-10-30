vcpkg_fail_port_install(ON_TARGET "OSX")

find_program(ZEDFU
    NAMES ZEDfu.exe ZEDfu
    PATHS
      $ENV{ZED_SDK_ROOT_DIR}
      /usr/local/zed
    PATH_SUFFIXES app/ZEDfu tools
    NO_DEFAULT_PATH
)

message("ZED_SDK_ROOT_DIR: $ENV{ZED_SDK_ROOT_DIR}")
message("ZEDFU: ${ZEDFU}")

if (NOT ZEDFU)
    set(ZED_REQUIRED_VERSION "2.8")
    set(ZED_PATCH_VERSION ".3")
    if (VCPKG_TARGET_IS_WINDOWS)
        set(ZED_SDK_URL https://download.stereolabs.com/zedsdk/${ZED_REQUIRED_VERSION}/win)
        set(ZED_SDK_PACKAGE_NAME ZED_SDK_Windows_v${ZED_REQUIRED_VERSION}${ZED_PATCH_VERSION}.exe)
        set(ZED_SDK_SHA512 d81319486fa1c04eed59c66f143715bf03d5ce361ceca82550c4fa41aa218831e0f3d515e583f8c68d83b0a7a2ec268cbdab323ee94a4349435d8fc6d1ae74d6)
    else()
        set(ZED_SDK_URL https://download.stereolabs.com/zedsdk/${ZED_REQUIRED_VERSION}/ubuntu18)
        set(ZED_SDK_PACKAGE_NAME ZED_SDK_Ubuntu18_v${ZED_REQUIRED_VERSION}${ZED_PATCH_VERSION}.run)
        set(ZED_SDK_SHA512 5167b5b70faefcdae847d8386a6a680e405abf3cda53166e4f648a9f049c37bb1c25b03875914afdd05c7aef3fcb86f06115514e1f29368a5c35d9acec7bc415)
    endif()
    
    vcpkg_download_distfile(ARCHIVE
        URLS "${ZED_SDK_URL}"
        FILENAME "${ZED_SDK_PACKAGE_NAME}"
        SHA512 ${ZED_SDK_SHA512}
    )
    
    if (VCPKG_TARGET_IS_WINDOWS)
        # ZED-SDK windows package does not support quite/auto install
        message(FATAL_ERROR "Please execute ${DOWNLOADS}/${ZED_SDK_PACKAGE_NAME} manually and restart computer before install port zedsdk.")
    else()
        # Modify the package permission
        vcpkg_execute_required_process(
            COMMAND chmod u+w ${DOWNLOADS}/${ZED_SDK_PACKAGE_NAME}
            WORKING_DIRECTORY ${DOWNLOADS}
        )
        
        vcpkg_execute_required_process(
            COMMAND ${DOWNLOADS}/${ZED_SDK_PACKAGE_NAME} --quiet -- silent # DO NOT move the space between "--" and "silent"
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
            LOGNAME install-${PORT}
        )
    endif()
endif()
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
