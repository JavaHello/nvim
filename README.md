# NVIM IDE

使用 [NvChad](https://github.com/NvChad/NvChad) 做为基础配置, `NvChad` 基础配置和快捷建未做修改, 建议先阅读 `NvChad` 相关的文档。
主要添加了 `Java`, `Python`, `Rust` 语言的 `LSP`, `DAP` 配置

## 安装

### Linux, Mac

```sh
cd ~/.config
git clone  https://github.com/JavaHello/nvim.git
```

### Windows

```sh
cd $env:LOCALAPPDATA
git clone  https://github.com/JavaHello/nvim.git
```

## 依赖

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [JDK](https://openjdk.org/) 8/17+
- [maven](https://maven.apache.org/)
- [nodejs](https://nodejs.org/en)
- [yarn](https://yarnpkg.com/)

其他依赖可选安装,使用 [mason.nvim](https://github.com/williamboman/mason.nvim)

> 此配置在 Linux, Mac 系统上长期使用, Windows 下推荐使用 [scoop](https://scoop.sh/) 安装依赖

## 快捷键

|              功能               |         模式         |           按键            |
| :-----------------------------: | :------------------: | :-----------------------: |
|            文件管理             |       `Normal`       |        `<leader>e`        |
|            文件搜索             |       `Normal`       |       `<leader>ff`        |
|            全局搜索             | `Normal` or `Visual` |       `<leader>fw`        |
|          全局搜索替换           | `Normal` or `Visual` |       `<leader>fr`        |
|            Git 操作             |      `Command`       |          `:Git`           |
|             Outline             |       `Normal`       |        `<leader>o`        |
|            查看实现             |       `Normal`       |           `gi`            |
|            查看引用             |       `Normal`       |           `gr`            |
|            查看声明             |       `Normal`       |           `gd`            |
|      格式化(LSP 提供支持)       | `Normal` or `Visual` |       `<leader>fm`        |
|             重命名              |       `Normal`       |       `<leader>ra`        |
|           Code Action           |       `Normal`       |       `<leader>ca`        |
|              Debug              |       `Normal`       |      `:DapContinue`       |
|              断点               |       `Normal`       |       `<leader>db`        |
|            内置终端             |      `Command`       |     `<A-h> or <A-v>`      |
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

### Spring Boot LS

- 依赖 vscode 插件 [VScode Spring Boot](https://marketplace.visualstudio.com/items?itemName=vmware.vscode-spring-boot)
- [x] 查找`symbols`,`bean`定义，`bean`引用，`bean`实现等。
- [x] `application.properties`, `application.yml` 文件提示
