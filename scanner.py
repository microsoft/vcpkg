import html
import http
import gzip
import urllib.request
import json
import smtplib
from email.message import EmailMessage
import datetime

def get_github():
    githubdoc = []

    with urllib.request.urlopen('https://api.github.com/search/issues?q=vcpkg+-repo:microsoft/vcpkg&sort=updated&per_page=30') as res:
        doc = res.read().decode('utf-8')
        jdoc = json.loads(doc)
        print("total count = {}".format(jdoc['total_count']))
        today = datetime.datetime.utcnow()
        if 'items' in jdoc:
            for item in jdoc['items'][:30]:
                updated_at = item['updated_at']
                dt_updated_at = datetime.datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%SZ")
                if today - dt_updated_at > datetime.timedelta(days=3):
                    break
                repo = item['repository_url'][29:]
                githubdoc.append("""<div class="github"><div>{} comments</div><div>updated {}</div><div>{}</div><div><a href="{}">{}</a></div></div>""".format(item['comments'], updated_at, repo, item['html_url'], html.escape(item['title'])))

    return "<h2>Github last 3 days ({} issues+PRs)</h2>{}".format(len(githubdoc), "".join(githubdoc))

def get_google():
    googledoc = []

    with urllib.request.urlopen('https://www.googleapis.com/customsearch/v1?key=AIzaSyAgDJeOcCtOgYSLPboFLf_3SsV9TqSYTFE&cx=016162264654347836401:8cwjt4hwu-k&q=vcpkg+-site:github.com&dateRestrict=d5&exactTerms=vcpkg') as res:
        jdoc = json.loads(res.read().decode('utf-8'))
        for item in jdoc['items'][:30]:
            googledoc.append("""<div class="google"><div><a href="{}">{}</a></div><div>{}</div></div>""".format(item['htmlFormattedUrl'], item['htmlTitle'][:120], item['htmlSnippet']))

    return "<h2>Google last 4 days ({} hits)</h2>{}".format(len(googledoc), "".join(googledoc))

def get_stackoverflow():
    stackdoc = []

    fromdate = (datetime.datetime.now() - datetime.timedelta(days=14)).timestamp()
    url = 'https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=vcpkg&site=stackoverflow&fromdate={}'.format(int(fromdate))
    http.client.HTTPConnection.debuglevel = 1
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Accept-Encoding": "gzip"})) as res:
        doc1 = res.read()
        doc = gzip.decompress(doc1)
        jdoc = json.loads(doc.decode('utf-8'))
        for item in jdoc['items'][:30]:
            activitydate = datetime.datetime.fromtimestamp(int(item['last_activity_date'])).isoformat()
            stackdoc.append("""<div class="stacko"><div><a href="{}">{}</a></div><div>Last Activity: {}</div><div>views: {}</div></div>""".format(item['link'], html.escape(item['title']), activitydate, item['view_count']))
    return "<h2>Stackoverflow last 14 days ({} posts)</h2>{}".format(len(stackdoc), "".join(stackdoc))

stackodoc = get_stackoverflow()
googledoc = get_google()
githubdoc = get_github()

msg = EmailMessage()
msg.set_content("""<style>.github { margin: 10px 0px; border-left: 3px #aaf solid; background-color: #eef; }"""
    + """ .google { margin: 10px 0px; border-left: 3px #afa solid; background-color: #efe; }"""
    + """ .stacko { margin: 10px 0px; border-left: 3px #faa solid; background-color: #fee; }"""
    +""" </style>""" + githubdoc + googledoc + stackodoc + "<div>end of message</div>", subtype='html')

msg['Subject'] = '[vcpkg] Automatic social analysis for vcpkg {}'.format(datetime.datetime.now().isoformat())
msg['From'] = "vcpkg.social.analysis@xyz123.noreply"
msg['To'] = "roschuma@microsoft.com,alkarata@microsoft.com,vcpkg@microsoft.com"

with smtplib.SMTP(host='microsoft-com.mail.protection.outlook.com', port=25, timeout=10) as smtp:
    print("connected")
    smtp.set_debuglevel(2)
    smtp.ehlo()
    print("ehlo")
    smtp.starttls()
    print("startls")
    smtp.ehlo()
    print("ehlo")
    smtp.send_message(msg)

print('Scan and email completed.')
