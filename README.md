# NVIM IDE

支持 `Java`, `Python`, `Rust` 语言的 `LSP`, `DAP` 配置

## 安装

### Linux, Mac

```sh
cd ~/.config
git clone  https://github.com/JavaHello/nvim.git
```

## 依赖

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [yazi](https://github.com/sxyazi/yazi)
- [JDK](https://openjdk.org/) 8/17+
- [maven](https://maven.apache.org/)
- [nodejs](https://nodejs.org/en)
- [yarn](https://yarnpkg.com/)

其他依赖可选安装,使用 [mason.nvim](https://github.com/williamboman/mason.nvim)

> 此配置在 Linux, Mac 系统上长期使用

## 快捷键

|              功能               |         模式         |           按键            |
| :-----------------------------: | :------------------: | :-----------------------: |
|            文件管理             |       `Normal`       |        `<leader>e`        |
|            文件搜索             |       `Normal`       |       `<leader>ff`        |
|            全局搜索             | `Normal` or `Visual` |       `<leader>fw`        |
|            Git 操作             |      `Command`       |          `:Git`           |
|             Outline             |       `Normal`       |        `<leader>o`        |
|            查看实现             |       `Normal`       |           `gi`            |
|            查看引用             |       `Normal`       |           `gr`            |
|            查看声明             |       `Normal`       |           `gd`            |
|      格式化(LSP 提供支持)       | `Normal` or `Visual` |          `<C-l>`          |
|             重命名              |       `Normal`       |       `<leader>rn`        |
|           Code Action           |       `Normal`       |       `<leader>ca`        |
|              Debug              |       `Normal`       |      `:DapContinue`       |
|              断点               |       `Normal`       |       `<leader>db`        |
|            内置终端             |      `Command`       |          `<A-i>`          |
|     Java: Junit Test Method     |       `Normal`       |       `<leader>dm`        |
|     Java: Junit Test Class      |       `Normal`       |       `<leader>dc`        |
|            Run Last             |       `Normal`       |       `<leader>dl`        |
|       Java: 更新项目配置        |      `Command`       |    `:JdtUpdateConfig`     |
| Java: 刷新 Main 方法 Debug 配置 |      `Command`       | `:JdtRefreshDebugConfigs` |
|       Java: 预览项目依赖        |      `Command`       |      `:JavaProjects`      |

更多配置参考 [mappings](./lua/mappings.lua) 文件

## Java 配置

- `maven pom.xml` 自动补全(目前需要[手动打包](https://www.bilibili.com/video/BV12N4y1f7Bh/))

- [NVIM 打造 Java IDE](https://javahello.github.io/dev/tools/NVIM-LSP-Java-IDE-vscode.html) 更新了配置，全部使用 vscode 扩展，简化安装步骤。

- [手动编译 Java 开发环境](https://github.com/JavaHello/nvim/wiki) 这里提供了一个编译脚本

### Spring Boot LS

- 依赖 vscode 插件 [VScode Spring Boot](https://marketplace.visualstudio.com/items?itemName=vmware.vscode-spring-boot)
- [x] 查找`symbols`,`bean`定义，`bean`引用，`bean`实现等。
- [x] `application.properties`, `application.yml` 文件提示

## GPT 功能

依赖 `DeepSeek` API

- 命令 `:GptChat` 开启对话窗, `<Enter>` 发送请求
- 命令 `:TransXXX` 翻译文本
- 在 `git` 提交窗口，快捷键 `<leader>cm` 生成 `git` 提交消息
