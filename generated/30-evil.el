;; [[file:../modules/30-evil.org::*配置][配置:1]]
(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; 这些缓冲区更适合一开始处于 Emacs 状态或 normal 状态。
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'help-mode 'normal)
  (evil-set-initial-state 'special-mode 'normal)

  ;; Escape 既退出 Evil insert，也负责中止普通 Emacs 操作。
  (keymap-global-set "<escape>" #'keyboard-escape-quit))
;; 配置:1 ends here
