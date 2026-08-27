;; [[file:../modules/70-programming.org::*用 Eglot 接入语言服务器][用 Eglot 接入语言服务器:1]]
(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure)
  :custom
  ;; 最后一个受管理缓冲区关闭时退出服务器，避免遗留后台进程。
  (eglot-autoshutdown t)
  ;; 服务器发起的工作区编辑直接应用，保持重命名等操作连续。
  (eglot-confirm-server-initiated-edits nil))

;; 初期不要全局自动启动。先在具体语言章节里逐一添加，例如：
;; (add-hook 'python-ts-mode-hook #'eglot-ensure)
;; 用 Eglot 接入语言服务器:1 ends here

;; [[file:../modules/70-programming.org::*建立跨语言代码命名空间][建立跨语言代码命名空间:1]]
(with-eval-after-load 'general
  ;; General 就绪后再把跨语言动作接入 Leader。
  (maeiee-leader
    "c" '(:ignore t :which-key "code")
    "c a" '(eglot-code-actions :which-key "actions")
    "c r" '(eglot-rename :which-key "rename")
    "c f" '(eglot-format-buffer :which-key "format")
    "c d" '(xref-find-definitions :which-key "definition")
    "c R" '(xref-find-references :which-key "references")))
;; 建立跨语言代码命名空间:1 ends here
