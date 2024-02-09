# Vcpkg: Genel bakış

[中文总览](README_zh_CN.md)
[Español](README_es.md)
[한국어](README_ko_KR.md)
[Français](README_fr.md)
[Tiếng Việt](README_vn.md)
[Türkçe](README_tr.md)

Vcpkg, Windows, Linux ve MacOS'ta C ve C++ kütüphanelerinizi yönetmenize yardımcı olur.
Bu araç ve ekosistem, sürekli değişim içinde olduğundan katkılarınızı her zaman sevecenlikle karşılıyoruz!

Eğer önceden vcpkg kullanmadıysanız ya da vcpkg'yi nasıl kullanabileceğinizi anlamaya çalışıyorsanız
[Başlarken](#başlarken) başlığına göz atabilirsiniz.

Vcpkg ile birlikte gelen komutların kısa açıklamalarına erişmek için `vcpkg help` kodunu kullanabilir ya da
`vcpkg help [command]` kodunu kullanarak belirli bir komudun açıklamalarına erişebilirsiniz.

* GitHub: paketler [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg), programlar [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool) adresindedir.
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), #vcpkg kanalı.
* Discord: [\#include \<C++\>](https://www.includecpp.org), #🌏vcpkg kanalı.
* Dokümantasyon: [Dokümantasyon](https://learn.microsoft.com/vcpkg)

# İçerik Listesi

- [Vcpkg: Genel bakış](#vcpkg-genel-bakış)
- [İçerik listesi](#içerik-listesi)
- [Başlarken](#başlarken)
    - [Hızlı Başlangıç: Windows](#hızlı-başlangıç-windows)
    - [Hızlı Başlangıç: Unix](#hızlı-başlangıç-unix)
    - [Linux Geliştirici Araçlarını Yükleme](#linux-geliştirici-araçlarını-yükleme)
    - [macOS Geliştirici Araçlarını Yükleme](#macos-geliştirici-araçlarını-yükleme)
    - [CMake'i vcpkg ile Kullanma](#cmakei-vcpkg-ile-kullanma)
        - [Visual Studio Code CMake Araçları](#visual-studio-code-cmake-araçları)
        - [Vcpkg'ı Visual Studio CMake Projeleriyle Birlikte Kullanma](#vcpkgı-visual-studio-cmake-projeleriyle-birlikte-kullanma)
        - [Vcpkg'ı CLion ile Kullanma](#vcpkgı-clion-ile-kullanma)
        - [Vcpkg'ı CMake ile Birlikte Alt Modül Olarak Kullanma](#vcpkgı-cmake-ile-birlikte-alt-modül-olarak-kullanma)
- [Tab-Tamamlama/Oto-Tamamlama](#tab-tamamlamaoto-tamamlama)
- [Örnekler](#örnekler)
- [Katkıda Bulunma](#katkıda-bulunma)
- [Lisans](#lisans)
- [Güvenlik](#güvenlik)
- [Telemetri](#telemetri)

# Başlarken

Öncelikle hızlı başlangıç  rehberlerinden birisini hangi işletim sistemini kullandığınıza bağlı olarak
[Windows](#hızlı-başlangıç-windows), ya da [macOS ve Linux](#hızlı-başlangıç-unix) takip etmelisiniz.

Daha fazla bilgi için, [Paketleri Yükleme ve Kullanma][getting-started:using-a-package] başlığına göz atabilirsiniz.
Eğer ihtiyacınız olan kütüphane vcpkg depolarında yoksa, vcpkg ekibinin ve topluluğun inceleyeceği, ve büyük olasılıkla paketi ekleyecekleri
[GitHub deposuna açıklamasıyla birlikte bir sorun gönderin][contributing:submit-issue]

Vcpkg inmiş, sorunsuz çalışıyorsa, belki [tab tamamlama](#tab-tamamlamaoto-tamamlama) özelliğini kabuk aracında görmek isteyebilirsiniz.

## Hızlı Başlangıç: Windows

Gerekenler:
- Windows 7 ya da daha güncel sürüm
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Güncelleştirme 3 ya da daha güncel sürüm, İngilizce dil paketiyle birlikte

Öncelikle, vcpkg'yi yükleyin ve çalıştırın; herhangi bir yere yükleyebilirsiniz, kullanılan depo her zaman ayrık bir şekilde işlemesi açısından
genellikle vcpkg'yi alt modül olarak kullanmayı tavsiye ederiz. Alternatif olarak, vcpkg dosya sisteminde genel dizine kurulabilir. Yine de,
bazı paket inşa sistemlerinde dizin hatalarını önlemek adına `C:\src\vcpkg` ya da `C:\dev\vcpkg` dizinlerini tavsiye ederiz.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Kütüphaneleri projenize yüklemek için çalıştırın:

```cmd
> .\vcpkg\vcpkg install [yüklenecek paketler]
```

Not: Üstteki kod varsayılan olarak x86 kütüphanelerini kurar. x64 için aşağıdaki kodu çalıştırın:

```cmd
> .\vcpkg\vcpkg install [paket]:x64-windows
```

Ya da

```cmd
> .\vcpkg\vcpkg install [yüklenecek paketler] --triplet=x64-windows
```

`search` alt komudunu kullanarak aramak istediğiniz kütüphaneleri depoda arayabilirsiniz:

```cmd
> .\vcpkg\vcpkg search [aranacak şey]
```

Vcpkg'ı Visual Studio ile birlikte kullanmak için aşağıdaki kodu çalıştırın (yönetici izni isteyebilir):

```cmd
> .\vcpkg\vcpkg integrate install
```

Bundan sonra, Yeni bir CMake dışı Proje oluşturabilirsiniz (ya da halihazırda olan bir projeyi açabilirsiniz).
Yüklenen kütüphaneler harici düzenlemelere ihtiyaç kalmaksızın direkt kod içinde dahil edilebilir.

Eğer CMake'i Visual Studio ile kullanıyorsanız [buradan](#vcpkgı-visual-studio-cmake-projeleriyle-birlikte-kullanma) devam edin.

Vcpkg'yi CMake ile IDE dışında kullanmak istiyorsanız, varsayılan araç zinciri dosyasını kullanın.

```cmd
> cmake -B [inşa dizini] -S . "-DCMAKE_TOOLCHAIN_FILE=[vcpkg dizini]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [inşa dizini]
```

CMake ile birlikte kütüphaneleri kullanmak için yine `find_package` ve benzeri komutlara ihtiyacınız olacak.
CMake'i bir IDE ile birlikte kullanma ve daha fazlası için [CMake başlığını](#cmakei-vcpkg-ile-kullanma) inceleyebilirsiniz.

## Hızlı Başlangıç: Unix

Linux için gerekenler:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

macOS için gerekenler:
- [Apple Geliştirici Araçları][getting-started:macos-dev-tools]

Öncelikle, vcpkg'yi yükleyin ve çalıştırın; herhangi bir yere kurulabilir. Yine de biz vcpkg'yi alt modül olarak
kullanmayı öneriyoruz.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Projenize kütüphaneleri yüklemek için çalıştırın:

```sh
$ ./vcpkg/vcpkg install [yüklenecek paketler]
```

`search` alt komudunu kullanarak ihtiyacınız olan paketleri arayabilirsiniz:

```sh
$ ./vcpkg/vcpkg search [aranacak şey]
```

CMake ile vcpkg'ı kullanmak için varsayılan araç zinciri dosyasını kullanabilirsiniz:

```sh
$ cmake -B [inşa dizini] -S . "-DCMAKE_TOOLCHAIN_FILE=[vcpkg dizini]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [inşa dizini]
```

CMake ile kullandığınızda da `find_package` ve benzeri komutlara ihtiyacınız olacak.
Vcpkg'ı CMake ve VSCode CMake araçlarıyla birlikte nasıl en iyi şekilde kullanabileceğinizi öğrenmek için  
[CMake başlığına](#cmakei-vcpkg-ile-kullanma) göz atabilirsiniz.

## Linux Geliştirici Araçlarını Yükleme

Yüklenecek paketler farklı Linux dağıtımları ve paket yöneticileri için teker teker ayrılmıştır.

- Debian, Ubuntu, popOS, ve diğer Debian tabanlı dağıtımlar için:

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential tar curl zip unzip
```

- CentOS

```sh
$ sudo yum install centos-release-scl
$ sudo yum install devtoolset-7
$ scl enable devtoolset-7 bash
```

Diğer dağıtımlar için g++ 6 veya güncel bir sürümü kurduğunuzdan emin olun.
Eğer spesifik bir dağıtım için içerik eklemek istiyorsanız, [bir PR atabilirsiniz][contributing:submit-pr]!

## macOS Geliştirici Araçlarını Yükleme

macOS'ta tek yapacağınız şey, aşağıdaki kodu çalıştırmak olacaktır:

```sh
$ xcode-select --install
```

Daha sonra ekranda belirecek kurucu araçtaki yönergeleri takip etmelisiniz.

Kurulum bittiğinde [hızlı başlangıç rehberindeki](#hızlı-başlangıç-unix) bilgileri kullanarak vcpkg'yi kurabilir ve çalıştırabilirsiniz.

## CMake'i vcpkg ile Kullanma

### Visual Studio Code CMake Araçları

Çalışma dizininizdeki `settings.json` dosyasına aşağıdaki kodu eklediğinizde CMake Araçları kütüphaneler için
otomatik olarak vcpkg'yi kullanacaktır:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg dizini]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Vcpkg'ı Visual Studio CMake Projeleriyle Birlikte Kullanma

CMake Ön Ayarlarını açın, `CMake araç zinciri dosyası` kısmına
vcpkg araç zinciri dosyasının bulunduğu dizini ekleyin:

```
[vcpkg dizini]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg'ı CLion ile Kullanma

Vcpkg CLion IDE'sine entegre şekilde gelmektedir.
Daha fazla detay için, [resmi dokümantasyonu](https://www.jetbrains.com/help/clion/package-management.html) inceleyebilirsiniz.

### Vcpkg'ı CMake ile Birlikte Alt Modül Olarak Kullanma

Vcpkg'ı projenizde alt modül olarak kullanacağınız zaman `CMAKE_TOOLCHAIN_FILE`'a eklemek yerine
CMakeLists.txt dosyanızın ilk `project()` çağrısından hemen önceki satıra aşağıdaki kodu ekleyebilirsiniz:

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

Bu, insanlara Vcpkg'yi kullanmama hakkını `CMAKE_TOOLCHAIN_FILE`'a ekleme imkanı vererek tanır. Ancak yine de,
ayarlama-inşa etme sürecini bir adım daha kolay kılacaktır.

[getting-started:using-a-package]: https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #linux-geliştirici-araçlarını-yükleme
[getting-started:macos-dev-tools]: #macos-geliştirici-araçlarını-yükleme
[getting-started:macos-brew]: #macos-geliştirici-araçlarını-yükleme
[getting-started:macos-gcc]: #macos-geliştirici-araçlarını-yükleme
[getting-started:visual-studio]: https://visualstudio.microsoft.com/

# Tab-Tamamlama/Oto-Tamamlama

`vcpkg` hem powershell hem bash'te komutların, paket adlarının
ve ayarların otomatik tamamlamasını destekler.
Tab-tamamlamayı aktif hale getirmek için kullandığınız kabuğa göre aşağıdaki kodlardan birisini
çalıştırın:

```pwsh
> .\vcpkg integrate powershell
```

ya da

```sh
$ ./vcpkg integrate bash # ya da zsh
```

hangi kabuğu kullandığınıza göre seçim yapın. Hemen ardından uçbiriminizi kapatıp açabilirsiniz.

# Örnekler

[Bir paketi yükleme ve kullanma](https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages),
[zip dosyasından paket ekleme](https://learn.microsoft.com/vcpkg/examples/packaging-zipfiles),
[GitHub deposundan paket ekleme](https://learn.microsoft.com/vcpkg/examples/packaging-github-repos) gibi
spesifik kullanım senaryoları için [dokümantasyon](https://learn.microsoft.com/vcpkg) adresini ziyaret edebilirsiniz.

Dokümantasyonlarımız https://vcpkg.io/ websitemizde çevrim içi bir biçimde sunulmaktadır.
Geri bildirimlerinizi önemsiyoruz! Sorun başlığı oluşturmak isterseniz https://github.com/vcpkg/vcpkg.github.io/issues adresinden oluşturabilirsiniz.

4 dakikalık [demo videosunu](https://www.youtube.com/watch?v=y41WFKbQFTw) izleyin.

# Katkıda Bulunma

Vcpkg açık kaynak bir projedir. Yani, sizin katkılarınızda inşa edilmiştir.
İşte katkıda bulunmanın birkaç yolu:

* [Sorunları Bildirin][contributing:submit-issue] in vcpkg or existing packages
* [Sorunları Çözün ve Yeni Paketler Ekleyin][contributing:submit-pr]

Daha fazla detay için [Katkıda Buluna Rehberi](CONTRIBUTING.md)'ne göz atın.

Bu proje [Microsoft Açık Kaynak Davranış Kurallarını][contributing:coc] benimser.
Daha fazla bilgi için [Davranış Kuralları SSS][contributing:coc-faq] sayfasını inceleyebilir,
sorularını ve yorumlarınızı [opencode@microsoft.com](mailto:opencode@microsoft.com) e-posta adresine gönderebilirsiniz.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# Lisans

Bu depodaki kodlar [MIT Lisansı](LICENSE.txt) altında lisanslanmıştır. Paketlerin lisansları esas yazarlarının adı
altında lisanslanmıştır. Eğer tanımlanmışsa, vcpkg lisans(ları) `installed/<triplet>/share/<port>/copyright` dizini altında tutar.

# Güvenlik

Vcpkg'deki birçok paket geliştiricinin kullandığı orijinal inşa sistemini kullanarak inşa edilir,
kaynak kodu resmi dağıtım kanallarından indirilir. Güvenlik duvarına takılmak istemiyorsanız, hangi paketlerin yüklendiğine bağlı
olarak özel erişim gerekebilir. Eğer en ufak bir iz bile bırakmak istemiyorsanız, öncelikle iz bırakmaktan çekinmeyeceğiniz bir
yerde kurulum yapın. [Önbelleğe alınan varlıkları](https://learn.microsoft.com/vcpkg/users/assetcaching) daha sonra "bir toz zerresi" dahi iz
bırakmak istemediğiniz sistemle paylaşın.

# Telemetri

vcpkg deneyiminizi iyileştirmek adına kullanım bilgilerini toplar.
Microsoft tarafından veriler tamamen anonim bir biçimde toplanır.
Telemetriyi kapatmanın farklı birkaç yolu vardır, istediğinizi seçebilirsiniz:
- bootstrap-vcpkg betiğini -disableMetrics argümanıyla çalıştırın.
- vcpkg'a komut satırında --disable-metrics argümanıyla çalıştırın.
- VCPKG_DISABLE_METRICS çevre değişkenini ayarlayın.

vcpkg telemetrisi hakkında daha fazla bilgi için [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).
