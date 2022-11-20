# Authentication for Source Code

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/authentication.md).**

Registries and `vcpkg_from_git()` directly use the git command line tools to fetch remote resources. Some of these resources may be protected from anonymous access and need authentication or credentials.

The strategies below all seek to achieve the same fundamental goal: `git clone https://....` should succeed without interaction. This enables vcpkg to be separated from the specifics of your authentication scheme, ensuring forwards compatibility with any additional security improvements in the future.

## Pre-seed git credentials

You can pre-seed git credentials via `git credential approve`:

Powershell:
```powershell
"url=https://github.com`npath=Microsoft/vcpkg`nusername=unused`npassword=$MY_PAT`n" | git credential approve
```
Bash:
```sh
echo "url=https://github.com"$'\n'"path=Microsoft/vcpkg"$'\n'"username=unused"$'\n'"password=$MY_PAT"$'\n' | git credential approve
```

## Bearer auth

For systems which need bearer auth, you can use `git config`:

**Note: you must make these config changes with `--global`**
```
git config --global --unset-all http.<uri>.extraheader
git config --global http.<uri>.extraheader "AUTHORIZATION: bearer <System_AccessToken>"
```
The `<uri>` can be filled in with a variety of options, documented in https://git-scm.com/docs/git-config#Documentation/git-config.txt-httplturlgt. For example, `https://dev.azure.com/MYORG/`.

(Original Source: https://github.com/Microsoft/azure-pipelines-agent/issues/1601#issuecomment-394511048).

**Note for Azure DevOps users:** You may need to enable access via Job authorization scope https://docs.microsoft.com/en-us/azure/devops/pipelines/process/access-tokens?view=azure-devops&tabs=yaml#job-authorization-scope. You may also need to "reference" the repo in your yaml via:

```yaml
resources: 
  repositories:
    - repository: <FRIENDLYNAME>
      type: git
      name: <ORG>/<REPO>
      tag: tags/<TAG>

...

jobs:
 - job: Build
   uses:
     repositories: [<FRIENDLYNAME>]
```

## Pass credentials in an environment variable (not recommended)

Using `VCPKG_KEEP_ENV_VARS` or `VCPKG_ENV_PASSTHROUGH_UNTRACKED`, we can smuggle credential info via another var like `MY_TOKEN_VAR`.
```sh
export VCPKG_KEEP_ENV_VARS=MY_TOKEN_VAR
export MY_TOKEN_VAR=abc123
```
This can then be used in your private ports:
```cmake
# some/private/portfile.cmake
set(MY_TOKEN_VAR "")
if(DEFINED ENV{MY_TOKEN_VAR})
    set(MY_TOKEN_VAR "$ENV{MY_TOKEN_VAR}@")
endif()
vcpkg_from_git(
    URLS "https://${MY_TOKEN_VAR}host.com/normal/url/path"
    ...
)
```
```cmake
# some/other/private/portfile.cmake
vcpkg_from_github(
    AUTHORIZATION_TOKEN "$ENV{MY_TOKEN_VAR}"
)
```

For private ports, we recommend using `vcpkg_from_git()` instead of `vcpkg_from_github()` and the pre-seeding method above.

## Pass Jenkins gitUsernamePassword credentials

The simplest and most secure option to Git authentication to GitHub from Jenkins is using [GitHub App](https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc) and the following:
```groovy
withCredentials([gitUsernamePassword(credentialsId: 'jenkins-github-app')]) {
  withEnv(['VCPKG_KEEP_ENV_VARS=GIT_ASKPASS']) {
    bat 'cmake'
  }
}
```
This sets the GIT_ASKPASS with a path to helper script which responds with git credentials query and instructs `vcpkg` to keep this environment variable. The password is a [GitHub App token](https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/) with 1 hour lifetime.
