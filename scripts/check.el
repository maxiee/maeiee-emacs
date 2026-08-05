;;; check.el --- Lightweight syntax check -*- lexical-binding: t; -*-

(defconst maeiee-emacs-root
  (file-name-directory
   (directory-file-name
    (file-name-directory
     (file-truename (or load-file-name buffer-file-name))))))

(add-to-list 'load-path (expand-file-name "lisp" maeiee-emacs-root))
(require 'maeiee-loader)

(dolist (command '(maeiee-tangle-module
                   maeiee-tangle-current-module
                   maeiee-reload-current-module))
  (unless (commandp command)
    (error "%S must be an interactive command" command)))

(maeiee-tangle-all)

(let ((failed nil))
  (dolist (file (directory-files maeiee-generated-directory t "\\.el\\'"))
    (condition-case err
        (with-temp-buffer
          (insert-file-contents file)
          (emacs-lisp-mode)
          (check-parens)
          (goto-char (point-min))
          (condition-case nil
              (while t
                (read (current-buffer)))
            (end-of-file nil))
          (message "OK  %s" (file-name-nondirectory file)))
      (error
       (setq failed t)
       (message "ERR %s: %s"
                (file-name-nondirectory file)
                (error-message-string err)))))
  (when failed
    (kill-emacs 1)))

;;; check.el ends here
