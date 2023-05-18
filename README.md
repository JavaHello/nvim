# NVIM IDE

可配置 `Java`, `Rust`, `C/C++`, `JavaScript` 等编程语言开发环境。 极速启动 (`startuptime` 20 ~ 70 ms)。

使用 `neovim v0.9.0`+ 版本。

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

> 此配置在 Linux, Mac, Windows (推荐使用 [scoop](https://scoop.sh/) 安装依赖) 系统上长期使用

## 快捷键

|              功能               |         模式         |           按键            |
| :-----------------------------: | :------------------: | :-----------------------: |
|            文件管理             |       `Normal`       |        `<leader>e`        |
|            文件搜索             |       `Normal`       |       `<leader>ff`        |
|            全局搜索             | `Normal` or `Visual` |       `<leader>fg`        |
|          全局搜索替换           | `Normal` or `Visual` |       `<leader>fr`        |
|          搜索 symbols           | `Normal` or `Visual` |       `<leader>fs`        |
|            Git 操作             |      `Command`       |    `:Neogit` or `:Git`    |
|             Outline             |       `Normal`       |        `<leader>o`        |
|            查看实现             |       `Normal`       |           `gi`            |
|            查看引用             |       `Normal`       |           `gr`            |
|            查看声明             |       `Normal`       |           `gd`            |
|      格式化(LSP 提供支持)       | `Normal` or `Visual` |        `<leader>=`        |
|             重命名              |       `Normal`       |       `<leader>rn`        |
|           Code Action           |       `Normal`       |       `<leader>ca`        |
|              Debug              |       `Normal`       |  `F5` or `:DapContinue`   |
|              断点               |       `Normal`       |       `<leader>db`        |
|           翻译 en->zh           | `Normal` or `Visual` |       `<leader>tz`        |
|           翻译 zh->en           | `Normal` or `Visual` |       `<leader>te`        |
|            内置终端             |      `Command`       |       `:ToggleTerm`       |
|           Tasks 列表            |       `Normal`       |       `<leader>ts`        |
|            代码折叠             |       `Normal`       |           `zc`            |
|            代码展开             |       `Normal`       |           `zo`            |
|     Java: Junit Test Method     |       `Normal`       |       `<leader>dm`        |
|     Java: Junit Test Class      |       `Normal`       |       `<leader>dc`        |
|            Run Last             |       `Normal`       |       `<leader>dl`        |
|       Java: 更新项目配置        |      `Command`       |    `:JdtUpdateConfig`     |
| Java: 刷新 Main 方法 Debug 配置 |      `Command`       | `:JdtRefreshDebugConfigs` |
|       Java: 预览项目依赖        |      `Command`       |      `:JavaProjects`      |

更多配置参考 [keybindings](./lua/kide/core/keybindings.lua) 文件

## Java 配置

> 如果不使用 `Java` 语言开发，无需配置

[NVIM 打造 Java IDE](https://javahello.github.io/dev/tools/NVIM-LSP-Java-IDE-vscode.html)
更新了配置，全部使用 vscode 扩展，简化安装步骤。

- 如果使用长时间后感觉卡顿，关闭下所有`buffer`, `:%bw`。
- 搜索依赖`jar`包`class`很慢的问题。在搜索框输入会频繁的请求`LSP server`导致内存和`CPU`提升,通常需要好几秒才会返回结果。建议复制类名称到搜索框，或者选择类名后按下`<leader>fs`, 这样会很快搜索出相关的`class`。

### 功能演示

<details>
<summary>启动页</summary>
  <img width="700" alt="启动页" src="https://javahello.github.io/dev/nvim-lean/images/home.png">
</details>

<details>
<summary>查找文件</summary>
  <img width="700" alt="查找文件" src="https://javahello.github.io/dev/nvim-lean/images/telescope-theme-1.png">
</details>

<details>
<summary>全局搜索</summary>
  <img width="700" alt="全局搜索" src="https://javahello.github.io/dev/nvim-lean/images/find-word.gif">
</details>

<details>
<summary>全局搜索替换</summary>
  <img width="700" alt="全局搜索替换" src="https://javahello.github.io/dev/nvim-lean/images/fr.gif">
</details>

<details>
<summary>文件管理</summary>
  <img width="700" alt="文件管理" src="https://javahello.github.io/dev/nvim-lean/images/file-tree.gif">
</details>

<details>
<summary>大纲</summary>
  <img width="700" alt="大纲" src="https://javahello.github.io/dev/nvim-lean/images/outline.gif">
</details>

<details>
<summary>查看引用</summary>
  <img width="700" alt="查看引用" src="https://javahello.github.io/dev/nvim-lean/images/java-ref-001.gif">
</details>

<details>
<summary>查看实现</summary>
  <img width="700" alt="查看实现" src="https://javahello.github.io/dev/nvim-lean/images/java-impl-002.gif">
</details>

<details>
<summary>搜索 symbols</summary>
  <img width="700" alt="搜索`symbols`" src="https://javahello.github.io/dev/nvim-lean/images/java-symbols-003.gif">
</details>

<details>
<summary>Debug</summary>
  <img width="700" alt="Debug" src="https://javahello.github.io/dev/nvim-lean/images/debug.gif">
</details>

<details>
<summary>JavaProjects</summary>
  <img width="700" alt="Debug" src="https://javahello.github.io/dev/nvim-lean/images/java-deps.png">
</details>

<details>
<summary>Maven(pom.xml 自动补全)</summary>
  <img width="700" alt="Debug" src="https://javahello.github.io/dev/nvim-lean/images/maven.png">
</details>

## 我的 VIM 插件列表

| 插件名称                                                              | 插件描述               | 推荐等级 | 备注 |
| --------------------------------------------------------------------- | ---------------------- | -------- | ---- |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                       | LSP 代码提示插件       | 10       |      |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)    | 模糊查找插件，窗口预览 | 10       |      |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)          | 状态栏插件             | 8        |      |
| [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)       | table 模式插件         | 8        |      |
| [toggletasks.nvim](https://github.com/jedrzejboczar/toggletasks.nvim) | 任务执行插件           | 8        |      |

## Neovim 插件列表

- Neovim 精选插件[yutkat/my-neovim-pluginlist](https://github.com/yutkat/my-neovim-pluginlist)
- Neovim 精选插件[rockerBOO/awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- Neovim 精选插件[neovimcraft](http://neovimcraft.com/)
- 推荐[NvChad](https://github.com/NvChad/NvChad), 部分插件和配置参考了 `NvChad`

## 感谢使用

打造一个高效美观的终端环境。欢迎提供各种建议，插件推荐，快捷键定义，主题配色等。
