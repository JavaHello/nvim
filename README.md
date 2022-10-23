# NVIM IDE

可配置 `Java`, `Rust`, `C/C++`, `JavaScript` 等编程语言开发环境。 极速启动 (60 ~ 100 ms), 注重细节。

使用 `neovim v0.8.0` 版本。

## 安装

### Linux, Mac

```sh
cd ~/.config
git clone  https://github.com/JavaHello/nvim.git
```

> 此配置在 Linux, Mac 系统上长期使用

### Windows

```sh
cd $env:LOCALAPPDATA
git clone  https://github.com/JavaHello/nvim.git
```

## 快捷键

|         功能         |         按键         |
| :------------------: | :------------------: |
|       文件管理       |     `<leader>e`      |
|       文件搜索       |     `<leader>ff`     |
|       全局搜索       |     `<leader>fg`     |
|     全局搜索替换     |     `<leader>fr`     |
|     搜索 symbols     |     `<leader>fs`     |
|       Git 操作       |      `:Neogit`       |
|       Outline        |     `<leader>o`      |
|       查看实现       |         `gi`         |
|       查看引用       |         `gr`         |
|       查看声明       |         `gd`         |
| 格式化(LSP 提供支持) |     `<leader>=`      |
|        重命名        |     `<leader>rn`     |
|     Code Action      |     `<leader>ca`     |
|        Debug         | `F5`or`:DapContinue` |
|         断点         |     `<leader>db`     |
|     翻译 en->zh      |     `<leader>tz`     |
|     翻译 zh->en      |     `<leader>te`     |
|       内置终端       |    `:ToggleTerm`     |
|      Tasks 列表      |     `<leader>ts`     |
|       代码折叠       |         `zc`         |
|       代码展开       |      `zo`or`l`       |

更多配置参考 [keybindings](./lua/kide/core/keybindings.lua) 文件

## Java 配置

> 如果不使用 `Java` 语言开发，无需配置

[NVIM 打造 Java IDE](https://javahello.github.io/dev/tools/NVIM-LSP-Java-IDE-vscode.html)
更新了配置，全部使用 vscode 扩展，简化安装步骤。

- 如果使用长时间后感觉卡顿，关闭下所有`buffer`, `:%bw`。
- 搜索依赖`jar`包`class`很慢的问题。在搜索框输入会频繁的请求`LSP server`导致内存和`CPU`提升,通常需要好几秒才会返回结果。建议复制类名称到搜索框，或者选择类名后按下`<leader>fs`, 这样会很快搜索出相关的`class`。

### 功能演示

- 启动页
  ![home](https://javahello.github.io/dev/nvim-lean/images/home.png)
- 查找文件
  ![find-file](https://javahello.github.io/dev/nvim-lean/images/telescope-theme-1.png)
- 全局搜索
  ![find-word](https://javahello.github.io/dev/nvim-lean/images/find-word.gif)
- 全局搜索替换
  ![fr](https://javahello.github.io/dev/nvim-lean/images/fr.gif)
- 文件管理
  ![file-tree](https://javahello.github.io/dev/nvim-lean/images/file-tree.gif)
- 大纲
  ![Outline](https://javahello.github.io/dev/nvim-lean/images/outline.gif)
- 查看引用
  ![001](https://javahello.github.io/dev/nvim-lean/images/java-ref-001.gif)
- 查看实现
  ![002](https://javahello.github.io/dev/nvim-lean/images/java-impl-002.gif)
- 搜索`class`,`method`,`field`等
  ![003](https://javahello.github.io/dev/nvim-lean/images/java-symbols-003.gif)
- Debug
  ![Debug001](https://javahello.github.io/dev/nvim-lean/images/debug.gif)

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
