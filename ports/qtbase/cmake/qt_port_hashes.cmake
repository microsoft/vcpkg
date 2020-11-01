set(QT_GIT_REF v6.0.0-beta2)

set(QT_PORTS qtbase 
             qttools 
             qtdeclarative
             qtsvg
             qt5compat
             qtshadertools
             qtquicktimeline
             qtquick3d
             qttranslations
             qtwayland
             qtdoc)

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_REF ${QT_GIT_REF})
endforeach()

set(qtbase_HASH             271c4ca2baa12b111837b36f2f2aed51ef84a62e2a3b8f9185a004330cb0a4c9398cf17468b134664de70ad175f104e77fa2a848466d33004739cdcb82d339ea)
set(qttools_HASH            d999603ce70b46864ca5597323c5ce71b58b5021c9e19948b4043aa712b99edcb91edabe122bc8d7792b4cccd53f3c5d70d966fd9d5f7205551803af8303e410)
set(qtdeclarative_HASH      9678a3c352896450ef49ede3eda6a7fe8cffdbf28dc91f9b5b2122dea69a070370f9ff6af31358398d5f058b530c7ae20a7df46a3905cd8dfe3deab66789b32c)

set(qtsvg_HASH              105ee59cfc16a3e3a1658253d0731dfeb5506bfe98378d7a402a4e54a403c2c95d35b336fd91b6ac8bad4fa548b1f0d794fb7186dfa43d615522f9f68c4a6da9)
set(qt5compat_HASH          dba33c315686d107c7e8854a628308e6c4a1f4127593e7bdeb8ece4e4fbf59aee3c218271c462374c138cecbb5ddbfbfaf63dc544789736d47e834da95200791)
set(qtshadertools_HASH      ecaa7d7574a97774d62f06939691fb892b1125b334879f9f9362789f2c6db1002214cb58f21035b72b9d2bd1f6bee5b855a39e997ffd4d0aee1217adf5ee778c)
set(qtquicktimeline_HASH    d02e85d2ee47b75537f526da00735149e8a9a83276bcbebc6cf3699607a51857493d719fa1fdf9f4df2c370da0b3bf1c0b507ddf7693ab55a0b7c24c5c49a85f)
set(qtquick3d_HASH          f7bae3e6057dbefb906e65bc2d38e20975dd7c19b9df599bc95fa8c178d39aeb15cc1ecaca711daadefcf24da47c58fd879f9fa819b87d6b13aba2e3fb856862)
set(qttranslations_HASH     78beb0ad5e1eb1992765fa44388115016bef5ef4e7e3864c389db5f639f5a3ac7b11c6e7792f07c015b7ecb2164015093a9d982e99feece4a54343c4290f28b7)
set(qtwayland_HASH          62431c4d048d8793e6295bfe5bae0804ca5800b5d62b26f5513d6bf7ac2189eee40c58821b1544b0fea667adfe7c74ce999fdaff3d0877479b84dd02e29c0a33)
set(qtdoc_HASH              2877026c663b696976ccc91dee578289bab457929f60fe5768d402647bc1d705321caa7ba44bdcf6f64c7d1481a5b0c95b14218de588c472414e332a14a61ef6)