;;; init.el --- Tiny loader for Maeiee Emacs -*- lexical-binding: t; -*-

;; This file intentionally contains almost no personal configuration.
;; bootstrap.sh symlinks it to ~/.emacs.d/init.el.  The symlink target tells us
;; where the Git repository lives, so the repository may be cloned anywhere.

(defconst maeiee-emacs-root
  (file-name-directory
   (directory-file-name
    (file-name-directory
     (file-truename (or load-file-name buffer-file-name)))))
  "Absolute path to the root of the Maeiee Emacs repository.")

(add-to-list 'load-path (expand-file-name "lisp" maeiee-emacs-root))

(require 'maeiee-loader)
(maeiee-load-configuration)

;;; init.el ends here
