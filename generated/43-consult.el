;; [[file:../modules/43-consult.org::*配置][配置:1]]
(use-package consult
  :demand t
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("M-y" . consult-yank-pop)
   ("s-f" . consult-line))
  :config
  (setq consult-narrow-key "<"))

(with-eval-after-load 'general
  (maeiee-leader
    "s" '(:ignore t :which-key "search")
    "s s" '(consult-line :which-key "line")
    "s r" '(consult-ripgrep :which-key "ripgrep")
    "s i" '(consult-imenu :which-key "imenu")

    "b b" '(consult-buffer :which-key "switch")))
;; 配置:1 ends here
