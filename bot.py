from datetime import date, datetime
import os;
import re;
import requests;
from dataclasses import dataclass

i = 0

@dataclass
class Tag:
  name: str
  sha: str
  date: datetime = None

def remove_comments(str: str) -> str:
  return re.split(r"\W*#", str)[0]

def find_repo(contents: str) -> str:
  pattern = re.compile(r"(\n\W+REPO\W)(.*)")
  match = re.findall(pattern, contents)
  
  if len(match) != 0 and len(match[0]) > 1:
      return remove_comments(match[0][1])
  else:
      return None

def find_ref(contents: str) -> str:
  pattern = re.compile(r"(\n\W+REF\W)(.*)")
  match = re.findall(pattern, contents)
  
  if len(match) != 0 and len(match[0]) > 1:
      return remove_comments(match[0][1])
  else:
      return None

def list_tags(repo: str) -> list:
  # Get all tags from repo
  tags = requests.get(f"https://api.github.com/repos/{repo}/tags").json()

  # iterate over tags and create Tag objects
  tag_list = []
  for tag in tags:
    tag_list.append(Tag(tag["name"], tag["commit"]["sha"]))

  # get commit date by commit sha
  for tag in tag_list:
    commit = requests.get(f"https://api.github.com/repos/{repo}/commits/{tag.sha}").json()
    tag.date = datetime.strptime(commit["commit"]["author"]["date"], "%Y-%m-%dT%H:%M:%SZ")

  return tag_list

with os.scandir('ports') as entries:
    for entry in entries:
        if i > 4:#20:
            break
        if not entry.is_dir():
            continue
        i += 1
        print(entry.name)
        with open("ports/" + entry.name + "/portfile.cmake") as fp:
          content = fp.read()
          if content.find("vcpkg_from_github") == -1:
            continue

          repo = find_repo(content)
          ref = find_ref(content)
          # Only Github is supported
          if repo is None or ref is None:
            continue
          print("\t" + repo + "@" + ref)
          result = requests.get("https://api.github.com/repos/" + repo + "/commits/" + ref)
          result_json = result.json()
          print("\t" + result_json["commit"]["author"]["date"])
          current_sha = result_json["sha"]
          current_date = result_json["commit"]["author"]["date"]
          tags = list_tags(repo)
          print(tags)
          
          




        """ pattern = re.compile(r"(\n\W+REF\W)(.*)")
        repo = re.findall(pattern, content)
        if len(repo) != 0 and len(repo[0]) > 1:
          result = re.split(r"\W*#", repo[0][1])
          print(result[0]) """