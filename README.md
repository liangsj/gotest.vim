# gotest.vim -- 仿vscode 的vim golang单测插件
vim golang单测插件
vim 需要支持 +Terminal 编译拓展
neovim 同步展示单测结果

# 安装 
plug 插件管理器安装
```
Plug 'liangsj/gotest.vim'
```

# 配置
```
let g:ATUO_LIST_FUNC = 1
0 : 不自动展示所有可以测试的函数
1 : 自动展示所有可以测试的函数
```

# 使用
在测试行执行 :GTest 命令，展示测试结果

# 效果展示
函数列表图
![image]( https://github.com/lexsaints/powershell/blob/master/IMG/ps2.png)
错误参数图
![image](https://github.com/liangsj/gotest.vim/blob/main/doc/error.jpg) 



