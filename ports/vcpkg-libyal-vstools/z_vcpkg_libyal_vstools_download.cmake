function(z_vcpkg_libyal_vstools_download OUT_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH path
        REPO libyal/vstools
        REF f412b5f4347839c31a6f7ff2a631990f84d81b40
        SHA512 f063a951af959e1fb4b52ca2dd028f416e5070573f4c25c012854db5b9ca90c334a3fd7f35c6f3092d2e7b9c0a889baba1cf221558a2406ac58fb7ad8d463f3e
        HEAD_REF main
    )
    set("${OUT_PATH}" "${path}" PARENT_SCOPE)
endfunction()