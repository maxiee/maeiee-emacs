;; [[file:../modules/01-core.org::*配置][配置:1]]
(defconst maeiee-backup-directory
  (expand-file-name "backups/" maeiee-var-directory))
(defconst maeiee-auto-save-directory
  (expand-file-name "auto-save/" maeiee-var-directory))

(make-directory maeiee-backup-directory t)
(make-directory maeiee-auto-save-directory t)

(setq custom-file (expand-file-name "custom.el" maeiee-var-directory)
      backup-directory-alist `(("." . ,maeiee-backup-directory))
      auto-save-file-name-transforms
      `((".*" ,maeiee-auto-save-directory t))
      auto-save-list-file-prefix
      (expand-file-name ".saves-" maeiee-auto-save-directory)
      version-control t
      kept-new-versions 10
      kept-old-versions 2
      delete-old-versions t
      backup-by-copying t)

(load custom-file 'noerror 'nomessage)

(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

(setq use-short-answers t
      ring-bell-function #'ignore
      sentence-end-double-space nil
      require-final-newline t)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 88)

(delete-selection-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)

(setq history-length 500
      recentf-max-saved-items 300
      global-auto-revert-non-file-buffers t)

(add-hook 'org-mode-hook #'maeiee-enable-module-auto-tangle)
;; 配置:1 ends here
