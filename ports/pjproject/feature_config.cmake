function(configure_pjproject_features)
    define_feature_mappings()

    foreach(FEATURE_NAME IN ITEMS "ssl" "opus" "video")
        configure_single_feature("${FEATURE_NAME}")
    endforeach()
endfunction()

macro(define_feature_mappings)
    set(FEATURE_VARS_ssl
        "PJ_HAS_SSL_SOCK"
    )

    set(FEATURE_VARS_opus
        "PJMEDIA_HAS_OPUS_CODEC"
    )

    set(FEATURE_VARS_video
        "PJSUA_HAS_VIDEO"
        "PJMEDIA_HAS_VIDEO"
        "PJMEDIA_HAS_FFMPEG"
        "PJMEDIA_HAS_VPX_CODEC"
        "PJMEDIA_HAS_VPX_CODEC_VP9"
        "PJMEDIA_HAS_LIBYUV"
        "PJMEDIA_VIDEO_DEV_HAS_SDL"
        "PJMEDIA_VIDEO_DEV_HAS_DSHOW"
    )
endmacro()

function(configure_single_feature FEATURE_NAME)
    if("${FEATURE_NAME}" IN_LIST FEATURES)
        set(FEATURE_VALUE 1)
    else()
        set(FEATURE_VALUE 0)
    endif()

    foreach(CONFIG_VAR IN LISTS FEATURE_VARS_${FEATURE_NAME})
        set(${CONFIG_VAR} ${FEATURE_VALUE} CACHE INTERNAL "Feature configuration variable")
    endforeach()
endfunction()

function(get_enabled_features OUTPUT_VAR)
    set(ENABLED_FEATURES)
    
    foreach(FEATURE IN ITEMS "ssl" "opus" "video")
        if("${FEATURE}" IN_LIST FEATURES)
            list(APPEND ENABLED_FEATURES "${FEATURE}")
        endif()
    endforeach()
    
    set(${OUTPUT_VAR} ${ENABLED_FEATURES} PARENT_SCOPE)
endfunction()

function(print_pjproject_configuration)
    message(STATUS "")
    message(STATUS "pjproject configuration summary:")
    message(STATUS "  Version: ${VERSION}")
    message(STATUS "  Platform: ${VCPKG_TARGET_ARCHITECTURE}")
    
    get_enabled_features(ENABLED_FEATURES)
    
    if(ENABLED_FEATURES)
        message(STATUS "  Enabled features: ${ENABLED_FEATURES}")
    else()
        message(STATUS "  Enabled features: none (base library only)")
    endif()
    
    message(STATUS "")
endfunction()