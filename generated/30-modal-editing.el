;; [[file:../modules/30-modal-editing.org::*文本编辑状态机][文本编辑状态机:1]]
(use-package evil
  :demand t
  :init
  ;; 允许 Evil 使用 Emacs 的通用集成接口，但把具体 mode 键位交给下一节处理。
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  ;; 在基础选项就绪后启用 Evil 状态机。
  (evil-mode 1)

  ;; 这些非文本缓冲区适合直接使用 normal state 浏览和退出。
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'help-mode 'normal)
  (evil-set-initial-state 'special-mode 'normal)

  ;; Escape 既离开 Evil insert state，也中止普通 Emacs 操作。
  (keymap-global-set "<escape>" #'keyboard-escape-quit))
;; 文本编辑状态机:1 ends here

;; [[file:../modules/30-modal-editing.org::*特殊界面的 Evil 适配][特殊界面的 Evil 适配:1]]
(use-package evil-collection
  :after evil
  :demand t
  :config
  ;; 一次性初始化已支持 major mode 的 Evil 键位集合。
  (evil-collection-init))
;; 特殊界面的 Evil 适配:1 ends here
