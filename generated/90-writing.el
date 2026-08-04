;; [[file:../modules/90-writing.org::*配置][配置:1]]
(defun maeiee-writing-mode ()
  "Toggle a simple distraction-reduced writing layout."
  (interactive)
  (if (bound-and-true-p olivetti-mode)
      (olivetti-mode -1)
    (olivetti-mode 1)))

(use-package olivetti
  :commands (olivetti-mode)
  :custom
  (olivetti-body-width 88))

(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :custom
  (markdown-command "pandoc"))

(with-eval-after-load 'general
  (maeiee-leader
    "t" '(:ignore t :which-key "toggle")
    "t w" '(maeiee-writing-mode :which-key "writing")
    "t l" '(display-line-numbers-mode :which-key "line numbers")
    "t v" '(visual-line-mode :which-key "visual lines")))
;; 配置:1 ends here
