;; [[file:../modules/70-eglot.org::*配置][配置:1]]
(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))

;; 初期不要全局自动启动。先在具体语言章节里逐一添加，例如：
;; (add-hook 'python-ts-mode-hook #'eglot-ensure)

(with-eval-after-load 'general
  (maeiee-leader
    "c" '(:ignore t :which-key "code")
    "c a" '(eglot-code-actions :which-key "actions")
    "c r" '(eglot-rename :which-key "rename")
    "c f" '(eglot-format-buffer :which-key "format")
    "c d" '(xref-find-definitions :which-key "definition")
    "c R" '(xref-find-references :which-key "references")))
;; 配置:1 ends here
