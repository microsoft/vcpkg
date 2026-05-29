#include <YandexDiskClient.h>
int main()
{
   YandexDiskClient yandex("TOKEN");
   auto quota = yandex.getQuotaInfo();
   return 0;
}
