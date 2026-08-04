;; [[file:../modules/60-magit.org::*配置][配置:1]]
(use-package magit
  :commands (magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1))

(with-eval-after-load 'general
  (maeiee-leader
    "g" '(:ignore t :which-key "git")
    "g g" '(magit-status :which-key "status")
    "g b" '(magit-blame-addition :which-key "blame")
    "g l" '(magit-log-current :which-key "log")))
;; 配置:1 ends here
