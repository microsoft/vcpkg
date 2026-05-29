#include <tgbot/tgbot.h>
using namespace TgBot;
int main()
{
   CurlHttpClient curlHttpClient;
   Bot bot("TOKEN", curlHttpClient);
   bot.getApi().deleteWebhook();
   auto fileContent = FileTools::read("file.txt");
   return 0;
}
