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

(defun maeiee--list-prefix-p (prefix list)
  "Return non-nil when PREFIX is equal to the first items in LIST."
  (or (null prefix)
      (and (consp list)
           (equal (car prefix) (car list))
           (maeiee--list-prefix-p (cdr prefix) (cdr list)))))

(defun maeiee--tree-contains-sequence-p (tree sequence)
  "Return non-nil when TREE contains adjacent items equal to SEQUENCE."
  (and (consp tree)
       (or (maeiee--list-prefix-p sequence tree)
           (maeiee--tree-contains-sequence-p (car tree) sequence)
           (maeiee--tree-contains-sequence-p (cdr tree) sequence))))

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

(defun maeiee--generated-contains-sequence-p (basename sequence)
  "Return non-nil when BASENAME contains adjacent forms in SEQUENCE."
  (let ((file (expand-file-name basename maeiee-generated-directory))
        (found nil))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (condition-case nil
          (while t
            (when (maeiee--tree-contains-sequence-p
                   (read (current-buffer))
                   sequence)
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

(defun maeiee--generated-definition-form (basename function)
  "Return the defun form for FUNCTION found in BASENAME, or nil."
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
                (setq found form))))
        (end-of-file nil)))
    found))

(defun maeiee--generated-defines-command-p (basename function)
  "Return non-nil when BASENAME defines interactive FUNCTION."
  (let ((file (expand-file-name basename maeiee-generated-directory))
        (found nil))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (condition-case nil
          (while t
            (let ((form (read (current-buffer))))
              (when (and (eq (car-safe form) 'defun)
                         (eq (cadr form) function)
                         (maeiee--tree-contains-p form '(interactive)))
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

(let* ((outline-binding
        '("w o"
          (quote
           (maeiee-outline-toggle :which-key "outline sidebar"))))
       (checks
        `((interactive-command
           . ,(maeiee--generated-defines-command-p
               "52-outline.el"
               'maeiee-outline-toggle))
          (right-side
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(imenu-list-position (quote right))))
          (width
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(imenu-list-size 32)))
          (clear-unsupported-buffer
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(imenu-list-persist-when-imenu-index-unavailable nil)))
          (automatic-update
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(imenu-list-auto-update t)))
          (stable-scroll-position
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(imenu-list-update-current-entry nil)))
          (source-aware-update
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(advice-add
                 (quote imenu-list-update)
                 :around
                 (function maeiee-outline--update-from-source))))
          (navigation-only-renderer
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(advice-add
                 (quote imenu-list--insert-entry)
                 :override
                 (function maeiee-outline--insert-entry))))
          (outline-folding-disabled
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(add-hook
                 (quote imenu-list-major-mode-hook)
                 (function maeiee-outline--keep-all-entries-visible)
                 t)))
          (focus-independent-mouse-jump
           . ,(maeiee--generated-contains-p
               "52-outline.el"
               '(advice-add
                 action
                 :override
                 (function maeiee-outline--action-goto-entry))))
          (leader-binding
           . ,(maeiee--generated-contains-sequence-p
               "52-outline.el"
               outline-binding)))))
  (dolist (check checks)
    (unless (cdr check)
      (error "52-outline.el generic Outline check failed: %s" (car check)))))

(let ((update-definition
       (maeiee--generated-definition-form
        "52-outline.el"
        'maeiee-outline--update-from-source)))
  (unless update-definition
    (error "52-outline.el must define source-aware Outline refresh"))
  (eval update-definition))

(defvar imenu-list--displayed-buffer nil)
(unless (fboundp 'imenu-list-major-mode)
  (define-derived-mode imenu-list-major-mode special-mode "Test-Ilist"))

(let ((source-buffer (generate-new-buffer " *outline-source-test*"))
      (outline-buffer (generate-new-buffer " *outline-sidebar-test*"))
      updated-buffer)
  (unwind-protect
      (progn
        (with-current-buffer outline-buffer
          (imenu-list-major-mode))
        (let ((imenu-list--displayed-buffer source-buffer))
          (with-current-buffer outline-buffer
            (maeiee-outline--update-from-source
             (lambda (&rest _arguments)
               (setq updated-buffer (current-buffer))))))
        (unless (eq updated-buffer source-buffer)
          (error "Outline refresh must use its displayed source buffer"))
        (setq updated-buffer nil)
        (with-current-buffer source-buffer
          (maeiee-outline--update-from-source
           (lambda (&rest _arguments)
             (setq updated-buffer (current-buffer)))))
        (unless (eq updated-buffer source-buffer)
          (error "Source-buffer refresh must preserve its current buffer")))
    (kill-buffer source-buffer)
    (kill-buffer outline-buffer)))

(dolist (function '(maeiee-outline--keep-all-entries-visible
                    maeiee-outline--button-location
                    maeiee-outline--run-button-action
                    maeiee-outline--entry-source-marker))
  (let ((definition
         (maeiee--generated-definition-form "52-outline.el" function)))
    (unless definition
      (error "52-outline.el must define %S" function))
    (eval definition)))

(defvar imenu-list-buffer-name "*Ilist*")
(let ((outline-buffer (generate-new-buffer imenu-list-buffer-name))
      activated-buffer
      activated-position)
  (unwind-protect
      (with-current-buffer outline-buffer
        (insert "Entry")
        ;; Text-button actions receive a marker, not the original mouse event.
        ;; The selected window deliberately continues to show another buffer.
        (maeiee-outline--run-button-action
         (copy-marker (point-min))
         (lambda ()
           (setq activated-buffer (current-buffer)
                 activated-position (point)))))
    (kill-buffer outline-buffer))
  (unless (and (eq activated-buffer outline-buffer)
               (= activated-position 1))
    (error "Outline mouse action must use its button marker, not window focus")))

(require 'hideshow)
(with-temp-buffer
  (emacs-lisp-mode)
  (insert "(progn\n  (message \"hidden\")\n  (message \"content\"))\n")
  (goto-char (point-min))
  (hs-minor-mode 1)
  (hs-hide-block)
  (unless (invisible-p 10)
    (error "Outline folding test must begin with hidden content"))
  (maeiee-outline--keep-all-entries-visible)
  (when (or hs-minor-mode (invisible-p 10))
    (error "Outline must disable Hideshow and reveal every entry")))

(unless (maeiee--generated-contains-p
         "80-org.el"
         '(org-imenu-depth 8))
  (error "80-org.el must expose deep Org headings through Imenu"))

(unless (and (maeiee--generated-defines-p
              "80-org.el" 'maeiee-org--configure-imenu)
             (maeiee--generated-contains-p
              "80-org.el"
              '(org-mode . maeiee-org--configure-imenu)))
  (error "80-org.el must install its headline indexer independent of load order"))

(let ((definition
       (maeiee--generated-definition-form
        "80-org.el" 'maeiee-org--configure-imenu)))
  (eval definition))

(require 'imenu)
(with-temp-buffer
  (org-mode)
  ;; Reproduce an Org buffer created before Imenu's delayed adapter is ready.
  (setq-local imenu-create-index-function
              #'imenu-default-create-index-function)
  (maeiee-org--configure-imenu)
  (unless (eq imenu-create-index-function #'org-imenu-get-tree)
    (error "Org Imenu adapter must repair an already-open buffer")))

(with-temp-buffer
  (org-mode)
  (setq-local org-imenu-depth 8)
  (insert "* L1\n** L2\n******** L8\n********* L9\n")
  (let ((index (imenu--make-index-alist t)))
    (unless (and (maeiee--tree-contains-p index "L1")
                 (maeiee--tree-contains-p index "L2")
                 (maeiee--tree-contains-p index "L8")
                 (not (maeiee--tree-contains-p index "L9")))
      (error "Org Imenu depth adapter produced an unexpected index: %S"
             index))
    ;; Org folding only changes overlays.  The complete Imenu tree must remain
    ;; identical when the source switches from expanded text to overview.
    (org-overview)
    (let ((folded-index (imenu--make-index-alist t)))
      (unless (equal index folded-index)
        (error "Org source folding must not change Outline entries: %S"
               folded-index)))))

(with-temp-buffer
  (org-mode)
  (setq-local org-imenu-depth 8)
  (insert "* Parent\n** Child\n")
  (let* ((index (imenu--make-index-alist t))
         (parent
          (cl-find-if
           (lambda (entry)
             (and (stringp (car-safe entry))
                  (string= (substring-no-properties (car entry)) "Parent")))
           index))
         (marker (maeiee-outline--entry-source-marker parent)))
    (unless (and (markerp marker)
                 (eq (marker-buffer marker) (current-buffer))
                 (= (marker-position marker) (point-min)))
      (error "Org parent headings must remain navigable from Outline: %S"
             parent))))

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
