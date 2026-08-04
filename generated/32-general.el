;; [[file:../modules/32-general.org::*配置][配置:1]]
(use-package which-key
  :demand t
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.45))

(use-package general
  :after evil
  :demand t
  :config
  (general-create-definer maeiee-leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-c SPC")

  (maeiee-leader
    "SPC" '(execute-extended-command :which-key "M-x")

    "f" '(:ignore t :which-key "file")
    "f f" '(find-file :which-key "find file")
    "f s" '(save-buffer :which-key "save")
    "f r" '(recentf-open-files :which-key "recent")
    "f c" '(maeiee-open-configuration :which-key "config")

    "b" '(:ignore t :which-key "buffer")
    "b b" '(switch-to-buffer :which-key "switch")
    "b k" '(kill-current-buffer :which-key "kill")
    "b n" '(next-buffer :which-key "next")
    "b p" '(previous-buffer :which-key "previous")

    "w" '(:ignore t :which-key "window")
    "w d" '(delete-window :which-key "delete")
    "w o" '(delete-other-windows :which-key "only")
    "w s" '(split-window-below :which-key "split below")
    "w v" '(split-window-right :which-key "split right")

    "h" '(:ignore t :which-key "help")
    "h f" '(describe-function :which-key "function")
    "h v" '(describe-variable :which-key "variable")
    "h k" '(describe-key :which-key "key")
    "h m" '(describe-mode :which-key "mode")))
;; 配置:1 ends here
