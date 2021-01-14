macro(download_quickcpplib dst_path)
    vcpkg_from_github(
        OUT_SOURCE_PATH QC_SOURCE_PATH
        REPO ned14/quickcpplib
        REF 408b6a80b087e8363884f20c31d942a032c36fc3
        SHA512 0794b7ade3e84a0d2166304834e53f8fd2d7dc505d8605e0d79bcb22cc0e76da5bfca15b2cfc032fe4103131cf8722a3513bd0b037f1e775a7d1cefc52b6bf2f
        HEAD_REF master
    )
    # Dependencies
    vcpkg_from_github(
        OUT_SOURCE_PATH BL_SOURCE_PATH
        REPO martinmoene/byte-lite
        REF 95b9aaccf00711afd9c18200533fcd82e1c6ce90
        SHA512 58a01cabebbb28b53a60ec50a243b68567f4980fac38bdbb9080407aca503fd645ffc68e7b9ceadfad3e3b03703364d0c193b3fdc2e67127458d8d28bd5c2c7e
        HEAD_REF master
    )
    
    file(COPY "${BL_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/byte")
    
    vcpkg_from_github(
        OUT_SOURCE_PATH GL_SOURCE_PATH
        REPO gsl-lite/gsl-lite
        REF 503b14bdd1cfa9a797dc3dddab6baac7e13504bf
        SHA512 132678663d115639d7a2b4038caf635d5e2134b25a8be5ed9abc73162f400b22d4c8793ab5b854e1119fe453e72bd32eb729837c0a0488f5fa14495008f8822a
        HEAD_REF master
    )
    
    file(COPY "${GL_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/gsl-lite")
    
    vcpkg_from_github(
        OUT_SOURCE_PATH OPT_SOURCE_PATH
        REPO akrzemi1/Optional
        REF 2b43315458a99fc5de1da6e7bc0ddd364b26d643
        SHA512 1952386cd3c7b963861f9634055e1baa4181d398d6f1b068a8a3f411368432bdcd42e47aadfa856584ed9a7c724a1c83369243ccb653e650af5c9155b42a84f4
        HEAD_REF master
    )
    
    file(COPY "${OPT_SOURCE_PATH}/." DESTINATION "${QC_SOURCE_PATH}/include/quickcpplib/optional")
    
    file(COPY "${QC_SOURCE_PATH}/." DESTINATION "${dst_path}")
endmacro()