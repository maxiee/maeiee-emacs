;; [[file:../modules/00-package.org::*配置][配置:1]]
(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(package-initialize)

(defconst maeiee-var-directory
  (expand-file-name "var/" user-emacs-directory))
(make-directory maeiee-var-directory t)

;; 只在新环境第一次启动时刷新索引，避免以后每次启动都访问网络。
(let ((marker (expand-file-name "package-archives-ready" maeiee-var-directory)))
  (unless (file-exists-p marker)
    (condition-case err
        (progn
          (package-refresh-contents)
          (with-temp-file marker
            (insert (format-time-string "%FT%T%z\n"))))
      (error
       (display-warning
        'maeiee-emacs
        (format "Package archive refresh failed: %s"
                (error-message-string err))
        :warning)))))

(require 'use-package)

(setq use-package-always-ensure t
      use-package-verbose init-file-debug
      use-package-compute-statistics t)
;; 配置:1 ends here
