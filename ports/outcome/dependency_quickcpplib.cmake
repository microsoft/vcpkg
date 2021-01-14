macro(download_quickcpplib dst_path)
    vcpkg_from_github(
        OUT_SOURCE_PATH QC_SOURCE_PATH
        REPO ned14/quickcpplib
        REF ${QUICKCPPLIB_REF}
        SHA512 ${QUICKCPPLIB_SHA512}
        HEAD_REF master
    )
    
    # Dependencies
    if(FEATURE_OPTIONS MATCHES "QUICKCPPLIB_USE_VCPKG_BYTE_LITE=ON")
      # Not sure what to do here?
    else()
      vcpkg_from_github(
          OUT_SOURCE_PATH BL_SOURCE_PATH
          REPO martinmoene/byte-lite
          REF ${BYTE_LITE_REF}
          SHA512 ${BYTE_LITE_SHA512}
          HEAD_REF master
      )
    endif()
    
    file(COPY "${BL_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/byte")
    
    if(FEATURE_OPTIONS MATCHES "QUICKCPPLIB_USE_VCPKG_GSL_LITE=ON")
      # Not sure what to do here?
    else()
      vcpkg_from_github(
          OUT_SOURCE_PATH GL_SOURCE_PATH
          REPO gsl-lite/gsl-lite
          REF ${GSL_LITE_REF}
          SHA512 ${GSL_LITE_SHA512}
          HEAD_REF master
      )
    endif()
    
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