;; [[file:../modules/32-command-interface.org::*让前缀键成为可发现的界面][让前缀键成为可发现的界面:1]]
(use-package which-key
  :demand t
  :config
  ;; 全局显示前缀键提示，并保留足够短但不过度打扰的等待时间。
  (which-key-mode 1)
  (setq which-key-idle-delay 0.45))
;; 让前缀键成为可发现的界面:1 ends here

;; [[file:../modules/32-command-interface.org::*建立稳定的 Leader 命名空间][建立稳定的 Leader 命名空间:1]]
(use-package general
  :after evil
  :demand t
  :config
  ;; 创建后续领域模块共同扩展的 Maeiee Leader 定义器。
  (general-create-definer maeiee-leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-c SPC")

  (maeiee-leader
    ;; Leader 后再次按 Space，进入 Emacs 的命令执行入口。
    "SPC" '(execute-extended-command :which-key "M-x")

    ;; 文件命名空间处理打开、保存、历史与配置仓库。
    "f" '(:ignore t :which-key "file")
    "f f" '(find-file :which-key "find file")
    "f s" '(save-buffer :which-key "save")
    "f r" '(recentf-open-files :which-key "recent")
    "f c" '(maeiee-open-configuration :which-key "config")

    ;; 缓冲区命名空间只放与当前 Emacs 会话对象有关的动作。
    "b" '(:ignore t :which-key "buffer")
    "b b" '(switch-to-buffer :which-key "switch")
    "b k" '(kill-current-buffer :which-key "kill")
    "b n" '(next-buffer :which-key "next")
    "b p" '(previous-buffer :which-key "previous")

    ;; 窗口命名空间调整布局，不负责项目文件树或 Outline 侧边栏。
    "w" '(:ignore t :which-key "window")
    "w d" '(delete-window :which-key "delete")
    "w o" '(delete-other-windows :which-key "only")
    "w s" '(split-window-below :which-key "split below")
    "w v" '(split-window-right :which-key "split right")

    ;; 帮助命名空间保留 Emacs 自解释系统的常用入口。
    "h" '(:ignore t :which-key "help")
    "h f" '(describe-function :which-key "function")
    "h v" '(describe-variable :which-key "variable")
    "h k" '(describe-key :which-key "key")
    "h m" '(describe-mode :which-key "mode")))
;; 建立稳定的 Leader 命名空间:1 ends here
