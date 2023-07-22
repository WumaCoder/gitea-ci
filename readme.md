# 全栈式搭建 Gitea CI\CD 系统 + 飞书机器人的解决方案

## 开篇

这篇文章主要帮助你构建一套完整的 CI/CD 系统，可以通过这个系统自动发版、代码检查等自动化操作，并且结合飞书的机器人可以将变更记录发在群里@对应的开发，从而提醒开发他的代码已上线请注意BUG。

目前我们的项目是一个小程序的项目，下面就已小程序作为例子说明。

## 功能

- 自动化 CI/CD 的系统（gitea）
  - 可以在不同服务器部署多个CI的执行机器人 runner
- 自动版本号 + CHANGELOG（release-it）
- 自动上传微信平台 （微信官方CI）
- 自动飞书的发版通知的消息卡片并且@对应开发（飞书SDK）
  - 消息卡片携带的功能
    - 下载sourcemap
    - 回退发版

## 准备

部署这个系统我们需要准备以下工具和资源：

- 一台公网服务器
  - 需要docker-compose环境
- 一个域名
- 一台打包机（可以是本地，也可以是公网）
- 微信小程序相关的KEY（APPID、APPSERCET）
- 飞书机器人相关的KEY（APPID、APPSERCET）
  - 需要先发布一个机器人
  - 而且需要若干权限（后面说明）
- 阿里云的OSS相关KEY
  - 用来上传sourcemap

## 关键工具

- gitea
  - 支撑整个CI系统的运行
- act_runner
  - 负责执行gitea的工作流脚本
- release-it
  - 核心执行脚本的工具，用来生成版本号、生成CHANGELOG
- gitea-cli
  - 自己封装的用来操作gitea服务的工具，比如同步镜像
- upload-ci
  - 自己封装的微信CI，包括自动上传sourcemap（使用阿里云）
- feishubot2
  - 自己封装的飞书机器人发送消息和消息回复工具

## 部署

首先我们需要在公网服务器部署 gitea 和 feishubot2 服务，这一步比较简单，因为我已经将他们封装成了命令工具，我们只需要在公网服务器上执行下面代码就可以：

```
```



## 踩过的坑

### gitea runner 的 label 配置的含义。

他这里的label表示 runner 可以在什么环境下运行，比如：

`mac:host` 表示的在运行runner的机器上运行。

`mac-centos:docker://centos:7` 表示在当前机器上使用docker运行，//centos:7表示使用centos7。

也就是他命名不只是命名，还存在一些配置含义，他的配置格式是这样的：

```
label[:schema[:args]]

label 就是下面runs-on填写的地方
:schema 表示运行方式 host 表示 主机，docker表示使用主机上的docker运行
```

我们在工作流`.github/workflows/publish.yaml` 中：

```yaml
name: Publish
run-name: ${{ github.actor }} Actions 🚀
on:
  push:
    branches:
      # - 'main'
      - "release/**"

jobs:
  Publish-Weapp-Actions:
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
    runs-on: macos # 这里写的内容就是上面的内容
    steps:
      - name: Check Env
      ....
```



下面是原文：

```
Gitea的Runner被称为act runner，因为它基于act。

与其他CIRunner一样，我们将其设计为Gitea的外部部分，这意味着它应该在与Gitea不同的服务器上运行。

为了确保Runner连接到正确的Gitea实例，我们需要使用令牌注册它。 此外，Runner通过声明自己的标签向Gitea报告它可以运行的Job类型。

之前，我们提到工作流文件中的 runs-on: ubuntu-latest 表示该Job将在具有ubuntu-latest标签的Runner上运行。 但是，Runner如何知道要运行 ubuntu-latest？答案在于将标签映射到环境。 这就是为什么在注册过程中添加自定义标签时，需要输入一些复杂内容，比如my_custom_label:docker://centos:7。 这意味着Runner可以接受需要在my_custom_label上运行的Job，并通过使用centos:7镜像的Docker容器来运行它。

然而，Docker不是唯一的选择。 act 也支持直接在主机上运行Job。 这是通过像linux_arm:host这样的标签实现的。 这个标签表示Runner可以接受需要在linux_arm上运行的Job，并直接在主机上运行它们。

标签的设计遵循格式label[:schema[:args]]。 如果省略了schema，则默认为host。

因此，

my_custom_label:docker://node:18：使用node:18 Docker镜像运行带有my_custom_label标签的Job。
my_custom_label:host：在主机上直接运行带有my_custom_label标签的Job。
my_custom_label：等同于my_custom_label:host。
my_custom_label:vm:ubuntu-latest：（仅为示例，未实现）使用带有ubuntu-latest ISO的虚拟机运行带有my_custom_label标签的Job。
```

具体可以细读这篇内容：[Gitea Actions设计 | Gitea Documentation](https://docs.gitea.com/zh-cn/next/usage/actions/design)

### 飞书机器人权限的问题。

我们在申请权限和需要进行发版才可让审核人员审核。



## 下一步

- 添加代码的质量检查
- 运行自动测试（使用微信开发工具的脚本录制）



## 结语

内容创作不易，该方案对您有用的话，请点一下stars，来鼓励一下创作者，有问题也可以回复或者issue。