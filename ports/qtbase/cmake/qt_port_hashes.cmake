set(QT_GIT_REF v6.0.0-beta2)

set(QT_PORTS qtbase qttools qtdeclarative)
foreach(_port IN LISTS QT_PORTS)
    set(${_port}_REF ${QT_GIT_REF})
endforeach()

set(qtbase_HASH         271c4ca2baa12b111837b36f2f2aed51ef84a62e2a3b8f9185a004330cb0a4c9398cf17468b134664de70ad175f104e77fa2a848466d33004739cdcb82d339ea)
set(qttools_HASH        d999603ce70b46864ca5597323c5ce71b58b5021c9e19948b4043aa712b99edcb91edabe122bc8d7792b4cccd53f3c5d70d966fd9d5f7205551803af8303e410)
set(qtdeclarative_HASH  9678a3c352896450ef49ede3eda6a7fe8cffdbf28dc91f9b5b2122dea69a070370f9ff6af31358398d5f058b530c7ae20a7df46a3905cd8dfe3deab66789b32c)