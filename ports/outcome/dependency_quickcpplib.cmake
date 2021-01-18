macro(determine_vcpkg_version prefix portfile)
    file(READ "${portfile}" contents)
    string(REGEX MATCH "REPO (.+)REF (.+)SHA512 ([0-9a-f]+)" match "${contents}")
    if(NOT match)
        message(FATAL_ERROR "FATAL: Failed to regex match portfile ${portfile}")
    endif()
    string(STRIP "${CMAKE_MATCH_2}" ${prefix}_REF)
    string(STRIP "${CMAKE_MATCH_3}" ${prefix}_SHA512)
    #message("${prefix}_REF=${${prefix}_REF} ${prefix}_SHA512=${${prefix}_SHA512}")
endmacro()

macro(download_quickcpplib dst_path)
    if(FEATURE_OPTIONS MATCHES "QUICKCPPLIB_USE_VCPKG_BYTE_LITE=ON")
      determine_vcpkg_version(BYTE_LITE "${CMAKE_CURRENT_LIST_DIR}/../byte-lite/portfile.cmake")
    endif()
    if(FEATURE_OPTIONS MATCHES "QUICKCPPLIB_USE_VCPKG_GSL_LITE=ON")
      determine_vcpkg_version(GSL_LITE "${CMAKE_CURRENT_LIST_DIR}/../gsl-lite/portfile.cmake")
    endif()

    vcpkg_from_github(
        OUT_SOURCE_PATH QC_SOURCE_PATH
        REPO ned14/quickcpplib
        REF ${QUICKCPPLIB_REF}
        SHA512 ${QUICKCPPLIB_SHA512}
        HEAD_REF master
    )
    
    # Dependencies
    vcpkg_from_github(
        OUT_SOURCE_PATH BL_SOURCE_PATH
        REPO martinmoene/byte-lite
        REF ${BYTE_LITE_REF}
        SHA512 ${BYTE_LITE_SHA512}
        HEAD_REF master
    )
    
    file(COPY "${BL_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/byte")
    
    vcpkg_from_github(
        OUT_SOURCE_PATH GL_SOURCE_PATH
        REPO gsl-lite/gsl-lite
        REF ${GSL_LITE_REF}
        SHA512 ${GSL_LITE_SHA512}
        HEAD_REF master
    )
    
    file(COPY "${GL_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/gsl-lite")
    
    vcpkg_from_github(
        OUT_SOURCE_PATH OPT_SOURCE_PATH
        REPO akrzemi1/Optional
        REF ${OPTIONAL_REF}
        SHA512 ${OPTIONAL_SHA512}
        HEAD_REF master
    )
    
    file(COPY "${OPT_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/optional")
    
    file(COPY "${QC_SOURCE_PATH}/." DESTINATION "${dst_path}")
endmacro()
