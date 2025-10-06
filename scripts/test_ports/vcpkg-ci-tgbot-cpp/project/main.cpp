#include <tgbot/tgbot.h>
#include <string>
using namespace TgBot;
int main()
{
   std::string token("TOKEN");
   CurlHttpClient curlHttpClient;
   Bot bot(token, curlHttpClient);
   bot.getApi().deleteWebhook();
   return 0;
}
