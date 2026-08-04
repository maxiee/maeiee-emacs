;; [[file:../modules/80-org.org::*配置][配置:1]]
(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0)
  (org-cycle-separator-lines 1)
  :config
  (require 'ob-emacs-lisp)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t))))

(with-eval-after-load 'general
  (maeiee-leader
    "o" '(:ignore t :which-key "org")
    "o c" '(org-capture :which-key "capture")
    "o a" '(org-agenda :which-key "agenda")
    "o t" '(maeiee-tangle-current-module :which-key "tangle module")
    "o r" '(maeiee-reload-current-module :which-key "reload module")))
;; 配置:1 ends here
