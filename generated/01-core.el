;; [[file:../modules/01-core.org::*文件状态与编辑器默认行为][文件状态与编辑器默认行为:1]]
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
;; 文件状态与编辑器默认行为:1 ends here

;; [[file:../modules/01-core.org::*可被不同交互层复用的命令][可被不同交互层复用的命令:1]]
;; 新建一个没有关联文件的缓冲区，并让它采用用户设置的初始 major mode。
(defun maeiee-new-empty-buffer ()
  "Create and switch to a new untitled buffer."
  (interactive)
  (switch-to-buffer (generate-new-buffer "untitled"))
  (funcall initial-major-mode))

;; 用 Dired 打开当前配置仓库，作为所有配置管理入口的共同底座。
(defun maeiee-open-configuration ()
  "Open this configuration repository."
  (interactive)
  (dired maeiee-emacs-root))

;; 优先在当前项目中查找文件；没有项目上下文时退回普通的 find-file。
(defun maeiee-quick-open ()
  "Find a file in the current project, or fall back to `find-file'."
  (interactive)
  (require 'project)
  (if (project-current)
      (call-interactively #'project-find-file)
    (call-interactively #'find-file)))
;; 可被不同交互层复用的命令:1 ends here
