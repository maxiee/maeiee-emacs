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

(defun maeiee--tree-contains-p (tree target)
  "Return non-nil when TREE contains a subtree equal to TARGET."
  (or (equal tree target)
      (and (consp tree)
           (or (maeiee--tree-contains-p (car tree) target)
               (maeiee--tree-contains-p (cdr tree) target)))))

(defun maeiee--generated-contains-p (basename target)
  "Return non-nil when generated file BASENAME contains TARGET."
  (let ((file (expand-file-name basename maeiee-generated-directory))
        (found nil))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (condition-case nil
          (while t
            (when (maeiee--tree-contains-p
                   (read (current-buffer))
                   target)
              (setq found t)))
        (end-of-file nil)))
    found))

(defun maeiee--generated-defines-p (basename function)
  "Return non-nil when generated file BASENAME defines FUNCTION."
  (let ((file (expand-file-name basename maeiee-generated-directory))
        (found nil))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (condition-case nil
          (while t
            (let ((form (read (current-buffer))))
              (when (and (eq (car-safe form) 'defun)
                         (eq (cadr form) function))
                (setq found t))))
        (end-of-file nil)))
    found))

(let ((leader-binding
       '("p t"
         (quote
          (maeiee-treemacs-toggle :which-key "toggle file tree")))))
  (unless (and
           (maeiee--generated-contains-p
            "51-treemacs.el"
            '(treemacs-position (quote left)))
           (maeiee--generated-defines-p
            "51-treemacs.el"
            'maeiee-treemacs-toggle)
           (maeiee--generated-contains-p
            "51-treemacs.el"
            leader-binding))
    (error "51-treemacs.el must configure a left sidebar at SPC p t")))

(let ((org-config
       (expand-file-name "80-org.el" maeiee-generated-directory))
      (cjk-wrap-setting '(word-wrap-by-category t))
      (found nil))
  (with-temp-buffer
    (insert-file-contents org-config)
    (goto-char (point-min))
    (condition-case nil
        (while t
          (when (maeiee--tree-contains-p
                 (read (current-buffer))
                 cjk-wrap-setting)
            (setq found t)))
      (end-of-file nil)))
  (unless found
    (error "%s must enable %S"
           (file-name-nondirectory org-config)
           cjk-wrap-setting)))

(customize-set-variable 'word-wrap-by-category t)
(unless (and (default-value 'word-wrap-by-category)
             (featurep 'kinsoku)
             (aref (char-category-set ?中) ?|)
             (aref (char-category-set ?，) ?>)
             (aref (char-category-set ?《) ?<))
  (error "CJK visual wrapping and kinsoku categories must be active"))

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
