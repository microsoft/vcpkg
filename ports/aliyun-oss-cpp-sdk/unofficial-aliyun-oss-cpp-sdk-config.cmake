find_path(ALIYUN_OSS_CPP_SDK_INCLUDE_DIR NAMES alibabacloud/oss/OssClient.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" NO_DEFAULT_PATH)
find_library(ALIYUN_OSS_CPP_SDK_LIBRARY_RELEASE NAMES alibabacloud-oss-cpp-sdk PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
find_library(ALIYUN_OSS_CPP_SDK_LIBRARY_DEBUG   NAMES alibabacloud-oss-cpp-sdk PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
if(NOT ALIYUN_OSS_CPP_SDK_INCLUDE_DIR OR NOT (ALIYUN_OSS_CPP_SDK_LIBRARY_RELEASE OR ALIYUN_OSS_CPP_SDK_LIBRARY_DEBUG))
    message(FATAL_ERROR "Broken installation of vcpkg port aliyun-oss-cpp-sdk")
endif()

function (parse_header_single_define filename var regex)
  set(__header_contents "")
  if (EXISTS ${filename})
    file(STRINGS ${filename} __header_contents REGEX "#define[ \t]+${var}[ \t]+\".+\"")
  endif ()
  if (__header_contents MATCHES "(${regex})")
    set(${var} ${CMAKE_MATCH_1} PARENT_SCOPE)
  else ()
    set(${var} "" PARENT_SCOPE)
  endif ()
endfunction ()

parse_header_single_define(${ALIYUN_OSS_CPP_SDK_INCLUDE_DIR}/alibabacloud/oss/Config.h ALIBABACLOUD_OSS_VERSION_STR "[0-9]+\\.[0-9]+\\.[0-9]+")

add_library(unofficial::aliyun-oss-cpp-sdk INTERFACE IMPORTED)

set_target_properties(unofficial::aliyun-oss-cpp-sdk PROPERTIES
                      INTERFACE_LINK_LIBRARIES "\$<\$<NOT:\$<CONFIG:DEBUG>>:${ALIYUN_OSS_CPP_SDK_LIBRARY_RELEASE}>;\$<\$<CONFIG:DEBUG>:${ALIYUN_OSS_CPP_SDK_LIBRARY_DEBUG}>"
                      INTERFACE_INCLUDE_DIRECTORIES "${ALIYUN_OSS_CPP_SDK_INCLUDE_DIR}")

set(aliyun-oss-cpp-sdk_VERSION "${ALIBABACLOUD_OSS_VERSION_STR}")
