;; [[file:../modules/60-version-control.org::*用 Magit 呈现 Git 工作流][用 Magit 呈现 Git 工作流:1]]
(use-package magit
  :commands (magit-status)
  :custom
  ;; 状态与操作界面复用当前窗口，diff 缓冲区保留专门布局。
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1))
;; 用 Magit 呈现 Git 工作流:1 ends here

;; [[file:../modules/60-version-control.org::*接入版本控制命名空间][接入版本控制命名空间:1]]
(with-eval-after-load 'general
  ;; General 就绪后再声明入口，保持前面模块的加载边界。
  (maeiee-leader
    "g" '(:ignore t :which-key "git")
    "g g" '(magit-status :which-key "status")
    "g b" '(magit-blame-addition :which-key "blame")
    "g l" '(magit-log-current :which-key "log")))
;; 接入版本控制命名空间:1 ends here
