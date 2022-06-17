# NVIM IDE

支持 `Java`, `Rust`, `C/C++`, `JavaScript` 等编程语言开发。

## Packer 插件管理器安装

### Linux, Mac

```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### Windows

```sh
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```

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

## 快捷键

|   功能   |    按键     |
| :------: | :---------: |
| Outline  | `<leader>o` |
| 查看实现 |    `gi`     |
| 查看引用 |    `gr`     |
| 查看声明 |    `gd`     |
|  Debug   |    `F5`     |
|   断点   | `<leader>b` |

## Java 配置

> 如果不使用 `Java` 语言开发，无需配置

[NVIM 打造 Java IDE](https://javahello.github.io/dev/tools/NVIM-LSP-Java-IDE.html)

### 功能演示

- 查看引用
  ![001](https://javahello.github.io/dev/nvim-lean/images/java-ref-001.gif)
- 查看实现
  ![002](https://javahello.github.io/dev/nvim-lean/images/java-impl-002.gif)
- 搜索`class`,`method`,`field`等
  ![003](https://javahello.github.io/dev/nvim-lean/images/java-symbols-003.gif)

## 我的 VIM 插件列表

| 插件名称                                                           | 插件描述               | 推荐等级 | 备注 |
| ------------------------------------------------------------------ | ---------------------- | -------- | ---- |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                    | LSP 代码提示插件       | 10       |      |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | 模糊查找插件，窗口预览 | 8        |      |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)       | 状态栏插件             | 8        |      |
| [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)    | table 模式插件         | 10       |      |

## Neovim 插件列表

- Neovim 精选插件[yutkat/my-neovim-pluginlist](https://github.com/yutkat/my-neovim-pluginlist)
- Neovim 精选插件[rockerBOO/awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- Neovim 精选插件[neovimcraft](http://neovimcraft.com/)
- 推荐[NvChad](https://github.com/NvChad/NvChad), 部分插件和配置参考了 `NvChad`

## 感谢使用

打造一个高效美观的终端环境。欢迎提供各种建议，插件推荐，快捷键定义，主题配色等。
