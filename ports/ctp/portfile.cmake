message(STATUS "Note: the downloading server may only be avilable from 8:00AM-5:00PM (UTC+8), Mon-Fri (except public holidays in China)")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(TRADEAPI_ARCHIVE
    URLS "http://www.sfit.com.cn/DocumentDown/api_3/5_2_2/v6.6.1_P1_tradeapi.zip"
    FILENAME "v6.6.1_P1_tradeapi.zip"
    SHA512 04d8ba233394fea04dacfa4bcb8758d9e068025ab3d963f6a89dcdfb79bbe10d58c10a71f630a039e130e4f8dfdc05cb4d1a52fd23d908f0798e43792d656cc4    
)

if("datacollect" IN_LIST FEATURES)
    # Data collect library is not included in this version, and official release note said we should get it from traderapi_v6.3.19_P1
    vcpkg_download_distfile(DATACOLLECT_ARCHIVE
        URLS "http://www.sfit.com.cn/DocumentDown/api_3/5_2_2/traderapi_v6.3.19_P1.zip"
        FILENAME "traderapi_v6.3.19_P1.zip"
        SHA512 ce44d761b2aebaaf131b91bcfc2fa0d5466c023310bcae1f03297fe228f62d2c281c09a82bb4068ae92ddd3d5ba00359b7b44b8c44af1181fff1954317d24bbb    
    )
endif()

vcpkg_extract_source_archive(
    TRADEAPI_UNPACK_PATH
    ARCHIVE ${TRADEAPI_ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if("datacollect" IN_LIST FEATURES)
    vcpkg_extract_source_archive(
        DATACOLLECT_UNPACK_PATH
        ARCHIVE ${DATACOLLECT_ARCHIVE}
        NO_REMOVE_ONE_LEVEL
    )
endif()


if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")   
    set(TRADEAPI_SOURCE_PATH "${TRADEAPI_UNPACK_PATH}/v6.6.1_P1_20210406_winApi/tradeapi/20210406_tradeapi_se_windows")
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(TRADEAPI_SOURCE_PATH "${TRADEAPI_UNPACK_PATH}/v6.6.1_P1_20210406_winApi/tradeapi/20210406_tradeapi64_se_windows")
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_extract_source_archive(
        TRADEAPI_LINUX_TAR_PATH
        ARCHIVE "${TRADEAPI_UNPACK_PATH}/v6.6.1_P1_20210406_api_tradeapi_linux64.tar"
    )
    set(TRADEAPI_SOURCE_PATH "${TRADEAPI_LINUX_TAR_PATH}/v6.6.1_P1_20210406_api_tradeapi_se_linux64")
else()
    message(FATAL_ERROR "${TARGET_TRIPLET} is not a supported platform" )
endif()

if("datacollect" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")   
        set(DATACOLLECT_SOURCE_PATH "${DATACOLLECT_UNPACK_PATH}/v6.3.19_P1_20200106_winApi/20200106_clientdll_windows")
    elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(DATACOLLECT_SOURCE_PATH "${DATACOLLECT_UNPACK_PATH}/v6.3.19_P1_20200106_winApi/20200106_clientdll64_windows")
    elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        vcpkg_extract_source_archive(
            DATACOLLECT_LINUX_TAR_PATH
            ARCHIVE "${DATACOLLECT_UNPACK_PATH}/v6.3.19_P1_20200106_api.tar"
        )
        set(DATACOLLECT_SOURCE_PATH "${DATACOLLECT_LINUX_TAR_PATH}/v6.3.19_P1_20200106_api_clientdatacollectdll_linux64")
    else()
        message(FATAL_ERROR "${TARGET_TRIPLET} is not a supported platform" )
    endif()
endif()


file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib")
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib")
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.dll")
elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.so")
    file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.so")
endif()

file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} FILES_MATCHING PATTERN "*.xml")
file(INSTALL ${TRADEAPI_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} FILES_MATCHING PATTERN "*.dtd")

if("datacollect" IN_LIST FEATURES)
    file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")

    if(VCPKG_TARGET_IS_WINDOWS)
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib")
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib")
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.dll")
    elseif(VCPKG_TARGET_IS_LINUX)
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.so")
        file(INSTALL ${DATACOLLECT_SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.so")
    endif()
    
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright By Shanghai Futures Information Technology Co.,Ltd")
