;;; maeiee-loader.el --- Load literate modules -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defvar maeiee-emacs-root
  (file-name-directory
   (directory-file-name
    (file-name-directory
     (file-truename (or load-file-name buffer-file-name)))))
  "Absolute path to the repository root.")

(defconst maeiee-modules-directory
  (expand-file-name "modules/" maeiee-emacs-root)
  "Directory containing literate Org configuration modules.")

(defconst maeiee-generated-directory
  (expand-file-name "generated/" maeiee-emacs-root)
  "Directory containing generated Emacs Lisp files.")

(defun maeiee--load-machine-local-file (name)
  "Load machine-local file NAME from `user-emacs-directory' when readable."
  (let ((file (expand-file-name name user-emacs-directory)))
    (when (file-readable-p file)
      (load file nil 'nomessage))))

(defun maeiee--module-files ()
  "Return module Org files in lexical order.

A two-digit numeric prefix is therefore the module load order."
  (sort
   (directory-files maeiee-modules-directory t
                    "\\`[0-9][0-9].*\\.org\\'")
   #'string<))

(defun maeiee--generated-file (org-file)
  "Return the generated Elisp path for ORG-FILE."
  (expand-file-name
   (concat (file-name-base org-file) ".el")
   maeiee-generated-directory))

(defun maeiee--needs-tangle-p (org-file el-file)
  "Return non-nil when ORG-FILE should be tangled to EL-FILE."
  (or (not (file-exists-p el-file))
      (file-newer-than-file-p org-file el-file)))

(defun maeiee-tangle-module (org-file)
  "Tangle the Emacs Lisp blocks in ORG-FILE and return the output path."
  (interactive
   (list
    (or (and buffer-file-name
             (file-in-directory-p
              (file-truename buffer-file-name)
              (file-truename maeiee-modules-directory))
             buffer-file-name)
        (user-error "Current buffer is not a Maeiee Emacs module"))))
  (require 'org)
  (require 'ob-tangle)
  (make-directory maeiee-generated-directory t)
  (let ((target (maeiee--generated-file org-file))
        (org-confirm-babel-evaluate nil))
    (org-babel-tangle-file org-file target "\\`emacs-lisp\\'")
    target))

(defun maeiee-load-module (org-file)
  "Tangle ORG-FILE when necessary, then load its generated Elisp."
  (let ((target (maeiee--generated-file org-file)))
    (when (maeiee--needs-tangle-p org-file target)
      (message "Tangling %s..." (file-name-nondirectory org-file))
      (maeiee-tangle-module org-file))
    (load target nil 'nomessage)))

(defun maeiee-tangle-all ()
  "Tangle every literate configuration module."
  (interactive)
  (dolist (org-file (maeiee--module-files))
    (maeiee-tangle-module org-file))
  (message "Maeiee Emacs: all modules tangled."))

(defun maeiee-reload-current-module ()
  "Tangle and reload the module visited by the current buffer."
  (interactive)
  (unless (and buffer-file-name
               (file-in-directory-p
                (file-truename buffer-file-name)
                (file-truename maeiee-modules-directory)))
    (user-error "Current buffer is not a Maeiee Emacs module"))
  (let ((target (maeiee-tangle-module buffer-file-name)))
    (load target nil 'nomessage)
    (message "Reloaded %s" (file-name-nondirectory buffer-file-name))))

(defun maeiee--tangle-current-module-after-save ()
  "Tangle the current module after saving it."
  (when (and buffer-file-name
             (file-in-directory-p
              (file-truename buffer-file-name)
              (file-truename maeiee-modules-directory)))
    (maeiee-tangle-module buffer-file-name)))

(defun maeiee-enable-module-auto-tangle ()
  "Enable buffer-local automatic tangling for configuration modules."
  (when (and buffer-file-name
             (file-in-directory-p
              (file-truename buffer-file-name)
              (file-truename maeiee-modules-directory)))
    ;; Only trusted configuration modules skip Babel confirmation.
    ;; Unrelated Org documents retain Org's safer default behavior.
    (setq-local org-confirm-babel-evaluate nil)
    (add-hook 'after-save-hook
              #'maeiee--tangle-current-module-after-save
              nil t)))

(defun maeiee-load-configuration ()
  "Load machine-local startup settings, modules, then local overrides.

The optional early-local.el is loaded before any module so settings needed by
startup network requests are available to 00-package.org.  The optional
local.el remains a final override layer."
  (make-directory maeiee-generated-directory t)
  (maeiee--load-machine-local-file "early-local.el")
  (dolist (org-file (maeiee--module-files))
    (condition-case err
        (maeiee-load-module org-file)
      (error
       (error "Maeiee Emacs failed while loading %s: %s"
              (file-name-nondirectory org-file)
              (error-message-string err)))))
  (maeiee--load-machine-local-file "local.el")
  (message "Maeiee Emacs loaded %d modules."
           (length (maeiee--module-files))))

(provide 'maeiee-loader)
;;; maeiee-loader.el ends here
