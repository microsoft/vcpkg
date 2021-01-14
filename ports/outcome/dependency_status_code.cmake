macro(download_status_code dst_path)
    vcpkg_from_github(
        OUT_SOURCE_PATH SC_SOURCE_PATH
        REPO ned14/status-code
        REF ${STATUS_CODE_REF}
        SHA512 ${STATUS_CODE_SHA512}
        HEAD_REF master
    )
    
    file(COPY ${SC_SOURCE_PATH}/. DESTINATION "${dst_path}")
endmacro()