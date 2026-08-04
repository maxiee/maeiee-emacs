;; [[file:../modules/50-project.org::*配置][配置:1]]
(use-package project
  :ensure nil
  :custom
  (project-switch-commands
   '((project-find-file "Find file" ?f)
     (project-find-regexp "Find regexp" ?g)
     (project-dired "Dired" ?d)
     (project-eshell "Eshell" ?e))))

(with-eval-after-load 'general
  (maeiee-leader
    "p" '(:ignore t :which-key "project")
    "p p" '(project-switch-project :which-key "switch")
    "p f" '(project-find-file :which-key "find file")
    "p g" '(project-find-regexp :which-key "grep")
    "p b" '(project-switch-to-buffer :which-key "buffer")
    "p d" '(project-dired :which-key "dired")))
;; 配置:1 ends here
