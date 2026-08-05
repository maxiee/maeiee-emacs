;; [[file:../modules/33-menu.org::*配置][配置:1]]
(use-package transient
  :demand t
  :custom
  (transient-enable-menu-navigation 'verbose))

(defun maeiee-config-menu--open-file (relative-file)
  "Open RELATIVE-FILE inside the Maeiee Emacs repository."
  (find-file (expand-file-name relative-file maeiee-emacs-root)))

(defmacro maeiee-config-menu-define-file-opener (name relative-file)
  "Define NAME as an interactive command opening RELATIVE-FILE."
  `(defun ,name ()
     ,(format "Open %s in the Maeiee Emacs repository." relative-file)
     (interactive)
     (maeiee-config-menu--open-file ,relative-file)))

(maeiee-config-menu-define-file-opener maeiee-config-menu-open-readme
  "README.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-bootstrap
  "bootstrap.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-roadmap
  "docs/ROADMAP.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-book
  "book/book.org")

(maeiee-config-menu-define-file-opener maeiee-config-menu-open-00-package
  "modules/00-package.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-01-core
  "modules/01-core.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-10-ui
  "modules/10-ui.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-20-macos
  "modules/20-macos.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-30-evil
  "modules/30-evil.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-31-evil-collection
  "modules/31-evil-collection.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-32-general
  "modules/32-general.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-33-menu
  "modules/33-menu.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-40-vertico
  "modules/40-vertico.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-41-orderless
  "modules/41-orderless.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-42-marginalia
  "modules/42-marginalia.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-43-consult
  "modules/43-consult.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-50-project
  "modules/50-project.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-60-magit
  "modules/60-magit.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-70-eglot
  "modules/70-eglot.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-80-org
  "modules/80-org.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-90-writing
  "modules/90-writing.org")

(defun maeiee-config-menu-find-file ()
  "Choose and open a human-maintained Org file from this repository."
  (interactive)
  (let* ((fixed-files '("README.org"
                        "bootstrap.org"
                        "docs/ROADMAP.org"
                        "book/book.org"))
         (module-files
          (mapcar (lambda (file)
                    (file-relative-name file maeiee-emacs-root))
                  (maeiee--module-files)))
         (relative-file
          (completing-read "配置文件: "
                           (append fixed-files module-files)
                           nil t)))
    (maeiee-config-menu--open-file relative-file)))

(defun maeiee-config-menu-magit-status ()
  "Open Magit status for the configuration repository."
  (interactive)
  (let ((default-directory maeiee-emacs-root))
    (call-interactively #'magit-status)))

(defun maeiee-config-menu--compile-target (target)
  "Run make TARGET from the configuration repository."
  (let ((default-directory maeiee-emacs-root))
    (compile (format "make %s" target))))

(defun maeiee-config-menu-check ()
  "Tangle and syntax-check every configuration module."
  (interactive)
  (maeiee-config-menu--compile-target "check"))

(defun maeiee-config-menu-doctor ()
  "Run the repository environment diagnostics."
  (interactive)
  (maeiee-config-menu--compile-target "doctor"))

(transient-define-prefix maeiee-config-menu ()
  "Open the Maeiee Emacs configuration control panel."
  [["开始"
    ("r"  "README 总览"       maeiee-config-menu-open-readme)
    ("b"  "bootstrap 自举"    maeiee-config-menu-open-bootstrap)
    ("d"  "ROADMAP 路线图"    maeiee-config-menu-open-roadmap)
    ("k"  "book 电子书"       maeiee-config-menu-open-book)]
   ["基础"
    ("00" "00 包管理"         maeiee-config-menu-open-00-package)
    ("01" "01 核心"           maeiee-config-menu-open-01-core)
    ("10" "10 界面"           maeiee-config-menu-open-10-ui)
    ("20" "20 macOS"          maeiee-config-menu-open-20-macos)]
   ["编辑"
    ("30" "30 Evil"           maeiee-config-menu-open-30-evil)
    ("31" "31 Evil Collection" maeiee-config-menu-open-31-evil-collection)
    ("32" "32 Leader"         maeiee-config-menu-open-32-general)
    ("33" "33 配置菜单"       maeiee-config-menu-open-33-menu)]]
  [["补全和项目"
    ("40" "40 Vertico"        maeiee-config-menu-open-40-vertico)
    ("41" "41 Orderless"      maeiee-config-menu-open-41-orderless)
    ("42" "42 Marginalia"     maeiee-config-menu-open-42-marginalia)
    ("43" "43 Consult"        maeiee-config-menu-open-43-consult)
    ("50" "50 Project"        maeiee-config-menu-open-50-project)]
   ["工具和写作"
    ("60" "60 Magit"          maeiee-config-menu-open-60-magit)
    ("70" "70 Eglot"          maeiee-config-menu-open-70-eglot)
    ("80" "80 Org"            maeiee-config-menu-open-80-org)
    ("90" "90 Writing"        maeiee-config-menu-open-90-writing)]
   ["管理"
    ("f" "查找配置文件"       maeiee-config-menu-find-file)
    ("D" "打开配置目录"       maeiee-open-configuration)
    ("s" "保存当前文件"       save-buffer)
    ("e" "重载当前模块"       maeiee-reload-current-module)
    ("a" "Tangle 全部模块"    maeiee-tangle-all)
    ("c" "运行配置检查"       maeiee-config-menu-check)
    ("x" "运行环境诊断"       maeiee-config-menu-doctor)
    ("g" "打开 Magit"         maeiee-config-menu-magit-status)
    ("q" "关闭菜单"           transient-quit-one)]])

(maeiee-leader
  "m" '(maeiee-config-menu :which-key "Maeiee 配置"))
;; 配置:1 ends here
