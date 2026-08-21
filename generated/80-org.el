;; [[file:../modules/80-org.org::*Org 文档的阅读与编辑体验][Org 文档的阅读与编辑体验:1]]
;; Org 是 Emacs 内置功能，不需要通过包管理器安装。
(defun maeiee-org--configure-cjk-emphasis-boundaries ()
  "Allow CJK punctuation around Org emphasis markers."
  (let ((components (copy-sequence org-emphasis-regexp-components)))
    ;; Remove our own punctuation before adding it so reloading stays idempotent.
    (dolist (index '(0 1))
      (setf (nth index components)
            (let ((component (nth index components)))
              (dolist (char (string-to-list maeiee-org-cjk-emphasis-punctuation))
                (setq component
                      (replace-regexp-in-string
                       (regexp-quote (char-to-string char)) ""
                       component t t)))
              (concat component maeiee-org-cjk-emphasis-punctuation))))
    ;; Org computes `org-emph-re' and `org-verbatim-re' from this variable.
    (org-set-emph-re 'org-emphasis-regexp-components components)))

(defcustom maeiee-org-cjk-emphasis-punctuation
  "，。！？；：、（）【】「」『』《》〈〉“”‘’〔〕［］｛｝…——"
  "CJK punctuation allowed next to Org emphasis markers."
  :type 'string
  :group 'org-appearance
  :set (lambda (symbol value)
         (set-default symbol value)
         ;; The setter may run before Org has been loaded.
         (when (and (boundp 'org-emphasis-regexp-components)
                    (fboundp 'org-set-emph-re))
           (maeiee-org--configure-cjk-emphasis-boundaries))))

(defun maeiee-org--configure-imenu ()
  "Use Org's complete headline tree as this buffer's Imenu index."
  ;; Org 9.7 only installs this adapter after Imenu loads.  Since imenu-list is
  ;; lazy-loaded, an Org buffer opened first can otherwise keep the generic
  ;; Lisp indexer and expose source-block forms instead of document headings.
  (setq-local imenu-create-index-function #'org-imenu-get-tree))

(use-package org
  :ensure nil
  ;; 打开 .org 文件时自动启用 org-mode。
  :mode ("\\.org\\'" . org-mode)
  ;; 不依赖 Org 与 Imenu 的加载先后顺序，始终安装标题索引器。
  :hook (org-mode . maeiee-org--configure-imenu)
  ;; 设置 Org Mode 的默认行为。
  :custom
  ;; 启用标题和内容的缩进显示，让层级结构更清晰。
  (org-startup-indented t)
  ;; 允许视觉软换行在中文字符之间选择断点，并遵循中文标点禁则。
  (word-wrap-by-category t)
  ;; 隐藏粗体、斜体等强调标记，只显示排版后的文字。
  (org-hide-emphasis-markers t)
  ;; 将 Org 实体（例如特殊字符）渲染成更易读的形式。
  (org-pretty-entities t)
  ;; 在 Org 源码块中使用对应语言的语法高亮。
  (org-src-fontify-natively t)
  ;; 让源码块中的 Tab 键遵循对应语言的缩进行为。
  (org-src-tab-acts-natively t)
  ;; 编辑源码块时不额外添加缩进，保持源码原本的列位置。
  (org-edit-src-content-indentation 0)
  ;; 设置标题循环时，标题之间保留一行分隔空白。
  (org-cycle-separator-lines 1)
  ;; 向通用 Imenu Outline 暴露最多八级 Org 标题。
  (org-imenu-depth 8)
  :config
  ;; 重新生成强调正则，使中文标点也能包围 =...=、~...~ 等行内标记。
  (maeiee-org--configure-cjk-emphasis-boundaries)
  ;; 重载模块时也修正已经打开、尚未获得 Org 索引器的缓冲区。
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
        (maeiee-org--configure-imenu)))))
;; Org 文档的阅读与编辑体验:1 ends here

;; [[file:../modules/80-org.org::*Evil Org Mode：让 Org 使用 Evil 风格][Evil Org Mode：让 Org 使用 Evil 风格:1]]
(use-package evil-org
  :ensure t
  :after (org evil)
  ;; 只在 Org 缓冲区启用 Evil Org 键位。
  :hook (org-mode . evil-org-mode)
  :config
  ;; 保留导航、插入、回车、文本对象和 Org 的附加操作。
  (evil-org-set-key-theme
   '(navigation insert return textobjects additional))
  ;; C-j/C-k 专门跳转标题，gj/gk 继续使用 evil-org 的 element 导航。
  (evil-define-key '(normal visual motion) 'evil-org-mode
    (kbd "C-j") #'org-next-visible-heading
    (kbd "C-k") #'org-previous-visible-heading)
  ;; 为 Org Agenda 设置对应的 Evil 键位。
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
;; Evil Org Mode：让 Org 使用 Evil 风格:1 ends here

;; [[file:../modules/80-org.org::*Org Babel：让文档成为可执行源码][Org Babel：让文档成为可执行源码:1]]
;; Org 加载后，再启用对应的 Babel 语言。
(with-eval-after-load 'org
  ;; 确保 Emacs Lisp 代码块的 Babel 支持已加载。
  (require 'ob-emacs-lisp)
  ;; 注册 Org Babel 支持的语言。
  (org-babel-do-load-languages
   ;; 修改 Org Babel 的语言配置变量。
   'org-babel-load-languages
   ;; 启用 Emacs Lisp 和 Shell 代码块。
   '((emacs-lisp . t)
     (shell . t))))
;; Org Babel：让文档成为可执行源码:1 ends here

;; [[file:../modules/80-org.org::*用快捷键连接 Org 的日常工作流][用快捷键连接 Org 的日常工作流:1]]
;; 等 general 包加载后，再注册 Org 相关的 leader 快捷键。
(with-eval-after-load 'general
  ;; 在 maeiee 的 leader 键下创建 Org 快捷键分组。
  (maeiee-leader
    ;; "o" 本身只是分组前缀，不绑定具体命令。
    "o" '(:ignore t :which-key "org")
    ;; 使用 "o c" 调用 Org Capture。
    "o c" '(org-capture :which-key "capture")
    ;; 使用 "o a" 打开 Org Agenda。
    "o a" '(org-agenda :which-key "agenda")
    ;; 使用 "o t" tangle 当前配置模块。
    "o t" '(maeiee-tangle-current-module :which-key "tangle module")
    ;; 使用 "o r" 重载当前配置模块。
    "o r" '(maeiee-reload-current-module :which-key "reload module")))
;; 用快捷键连接 Org 的日常工作流:1 ends here
