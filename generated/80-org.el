;; [[file:../modules/80-org.org::*配置][配置:1]]
;; 声明并配置 Org Mode。
(use-package org
  ;; Org 是 Emacs 内置功能，不需要通过包管理器安装。
  :ensure nil
  ;; 打开 .org 文件时自动启用 org-mode。
  :mode ("\\.org\\'" . org-mode)
  ;; 设置 Org Mode 的默认行为。
  :custom
  ;; 启用标题和内容的缩进显示，让层级结构更清晰。
  (org-startup-indented t)
  ;; 隐藏粗体、斜体等强调标记，只显示排版后的文字。
  (org-hide-emphasis-markers t)
  ;; 将 Org 实体（例如特殊字符）渲染成更易读的形式。
  (org-pretty-entities t)
  ;; 在 Org 源码块中使用对应语言的语法高亮。
  (org-src-fontify-natively t)
  ;; 让源码块中的 Tab 键遵循对应语言的缩进行为。
  (org-src-tab-acts-natively t)
  ;; 编辑源码块时不额外添加缩进，保持源码原本的列位置。
  (org-edit-src-content-indentation 0)
  ;; 设置标题循环时，标题之间保留一行分隔空白。
  (org-cycle-separator-lines 1)
  ;; 在 Org 配置加载完成后执行初始化代码。
  :config
  ;; 确保 Emacs Lisp 代码块的 Babel 支持已加载。
  (require 'ob-emacs-lisp)
  ;; 注册 Org Babel 支持的语言。
  (org-babel-do-load-languages
   ;; 修改 Org Babel 的语言配置变量。
   'org-babel-load-languages
   ;; 启用 Emacs Lisp 和 Shell 代码块。
   '((emacs-lisp . t)
     (shell . t))))

;; 等 general 包加载后，再注册 Org 相关的 leader 快捷键。
(with-eval-after-load 'general
  ;; 在 maeiee 的 leader 键下创建 Org 快捷键分组。
  (maeiee-leader
    ;; "o" 本身只是分组前缀，不绑定具体命令。
    "o" '(:ignore t :which-key "org")
    ;; 使用 "o c" 调用 Org Capture。
    "o c" '(org-capture :which-key "capture")
    ;; 使用 "o a" 打开 Org Agenda。
    "o a" '(org-agenda :which-key "agenda")
    ;; 使用 "o t" tangle 当前配置模块。
    "o t" '(maeiee-tangle-current-module :which-key "tangle module")
    ;; 使用 "o r" 重载当前配置模块。
    "o r" '(maeiee-reload-current-module :which-key "reload module")))
;; 配置:1 ends here
