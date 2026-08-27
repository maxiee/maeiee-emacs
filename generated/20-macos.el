;; [[file:../modules/20-macos.org::*修饰键与系统剪贴板][修饰键与系统剪贴板:1]]
(when (eq system-type 'darwin)
  ;; GNU Emacs 的 NS 端口。
  (when (boundp 'ns-command-modifier)
    (setq ns-command-modifier 'super))
  (when (boundp 'ns-option-modifier)
    (setq ns-option-modifier 'meta))
  (when (boundp 'ns-right-command-modifier)
    (setq ns-right-command-modifier 'super))
  (when (boundp 'ns-right-option-modifier)
    (setq ns-right-option-modifier 'meta))

  ;; emacs-mac 端口使用另一组变量；boundp 让同一配置兼容两种构建。
  (when (boundp 'mac-command-modifier)
    (setq mac-command-modifier 'super))
  (when (boundp 'mac-option-modifier)
    (setq mac-option-modifier 'meta))

  (setq select-enable-clipboard t
        select-enable-primary nil))
;; 修饰键与系统剪贴板:1 ends here

;; [[file:../modules/20-macos.org::*Command 键兼容层][Command 键兼容层:1]]
(keymap-global-set "s-a" #'mark-whole-buffer)
(keymap-global-set "s-c" #'kill-ring-save)
(keymap-global-set "s-x" #'kill-region)
(keymap-global-set "s-v" #'yank)
(keymap-global-set "s-z" #'undo-only)
(keymap-global-set "s-Z" #'undo-redo)

(keymap-global-set "s-s" #'save-buffer)
(keymap-global-set "s-o" #'find-file)
(keymap-global-set "s-n" #'maeiee-new-empty-buffer)
(keymap-global-set "s-w" #'kill-current-buffer)
(keymap-global-set "s-q" #'save-buffers-kill-terminal)

(keymap-global-set "s-f" #'isearch-forward)
(keymap-global-set "s-p" #'maeiee-quick-open)
(keymap-global-set "s-P" #'execute-extended-command)
(keymap-global-set "s-," #'maeiee-open-configuration)

(keymap-global-set "s-=" #'text-scale-increase)
(keymap-global-set "s-+" #'text-scale-increase)
(keymap-global-set "s--" #'text-scale-decrease)
(keymap-global-set "s-0" #'text-scale-adjust)

(keymap-global-set "s-<left>" #'beginning-of-line)
(keymap-global-set "s-<right>" #'end-of-line)
(keymap-global-set "s-<up>" #'beginning-of-buffer)
(keymap-global-set "s-<down>" #'end-of-buffer)
;; Command 键兼容层:1 ends here
