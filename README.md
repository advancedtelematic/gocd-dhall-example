# GoC Dhall example

## Introduction

This repo illustrates an example of creating GoCD pipelines using the [GoCD YAML Plugin](https://github.com/tomzo/gocd-yaml-config-plugin) and [Dhall](https://github.com/dhall-lang/dhall-lang) to create the YAML.

While it is possible to use this project as a template for your own dhall-based gocd configurations, do note that not all the fields the GoCD YAML Plugin have been added to `./types.dhall`

In this example there's two services, named "frontend" and "backend". They are configured in `./variables.dhall`. When `make print-yaml` is run, it will print out the GoCD YAML to STDOUT. These pipelines are for mocked build, test, deploy jobs for both the "frontend" and "backend" services, and a manual mocked end-to-end test that can be run afterwards.

That `make` target is evaluating the Dhall code in `pipelines.dhall`. This in turn imports `./build-test-deploy.dhall`, `./end-to-end-test.dhall` and `./environments.dhall`.

You can explore this repo starting from `pipelines.dhall`, and see from there how it builds the pipelines.

With the GoCD YAML plugin any file with the ending `.gocd.yaml` in a repo will be parsed and used to configure GoCD. This repo has the file `./pipelines.gocd.yaml`. If you change the dhall code and want to regenerate it run `make generate-yaml`.

## Test locally

The following steps stand up a local gitlab server, gocd server, and gocd agent in docker. You can then push this repo to the local gitlab server, configure the local gocd server with this project's `./pipelines.gocd.yaml` file, and run the pipelines on the local gocd agent. Note that following these steps the agent only supports jobs of type `script`.

Run the following Make targets

```
make run-gitlab-locally # takes a few minutes to start
make run-gocd-server
make run-gocd-agent
```

Add the line `127.0.0.1	gitlab.example.com` to `/etc/hosts`

Navigate to http://gitlab.example.com:30080 and create a root account password. Then login with the username `root` and the password you just created.

Click on your use icon in the top right, and click "Settings" in the drop down. Click "SSH Keys" and add your public key to SSH keys.

Use the "+" up the top of the UI and create a project: `gocd-dhall-example`. Make the project public.

```
git remote add local ssh://git@gitlab.example.com:30022/root/gocd-dhall-example.git
git push local master
```

Navigate to http://localhost:8153/ and go to the menu "Admin" -> "Config XML" and add this block after the `</server>` block:

```
<config-repos>
  <config-repo pluginId="yaml.config.plugin" id="repo1">
    <git url="http://gitlab.example.com:30080/root/gocd-dhall-example.git" branch="master" />
  </config-repo>
</config-repos>
```

Note that you may need to change the `branch` value if you are working on a branch other than master.

Now go to the "Agents" link at the top. You should see one agent (it's running in docker). Click the select button and click enable. This will run any `script` tasks, but not much else.

Go to the environments tab. Edit both environments and add the agent that you just enabled.

You should now be able to run the jobs in GoCD. If you make changes to the dhall, you can run `make generate-yaml`, then `git push local master`, and you should be able to see the changes in GoCD.

## License

This code is licensed under the Mozilla Public License 2.0, a copy of which can be found in this repository. All code is copyright 2018 HERE Europe B.V.
