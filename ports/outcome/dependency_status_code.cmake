macro(download_status_code dst_path)
    vcpkg_from_github(
        OUT_SOURCE_PATH SC_SOURCE_PATH
        REPO ned14/status-code
        REF 6befe8f7c79329b75a3b51e1ce28b5893b62b76d
        SHA512 b7020babab3a1ef8a5548afdd4678572c82d4c0b5e3f55c25fc136d10e0c948385702c7e2d190b2b5026fd043def034c7f6020412419c2eb553340ddce95ddf8
        HEAD_REF master
    )
    
    file(COPY ${SC_SOURCE_PATH}/. DESTINATION "${dst_path}")
endmacro()