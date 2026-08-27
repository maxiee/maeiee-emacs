;; [[file:../modules/33-config-management.org::*Transient 面板基础][Transient 面板基础:1]]
(use-package transient
  :demand t
  :custom
  ;; 显示完整的菜单导航提示，同时保留 Transient 原生鼠标按钮。
  (transient-enable-menu-navigation 'verbose))
;; Transient 面板基础:1 ends here

;; [[file:../modules/33-config-management.org::*打开固定文档与动态模块][打开固定文档与动态模块:1]]
(defun maeiee-config-menu--open-file (relative-file)
  "Open RELATIVE-FILE inside the Maeiee Emacs repository."
  ;; 所有路径都相对于仓库根目录解析，避免受当前缓冲区目录影响。
  (find-file (expand-file-name relative-file maeiee-emacs-root)))

(defmacro maeiee-config-menu-define-file-opener (name relative-file)
  "Define NAME as an interactive command opening RELATIVE-FILE."
  `(defun ,name ()
     ,(format "Open %s in the Maeiee Emacs repository." relative-file)
     (interactive)
     (maeiee-config-menu--open-file ,relative-file)))

;; 为三个稳定的起始文档定义可直接放入 Transient 的交互命令。
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-readme
  "README.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-bootstrap
  "bootstrap.org")
(maeiee-config-menu-define-file-opener maeiee-config-menu-open-roadmap
  "docs/ROADMAP.org")

(defun maeiee-config-menu-find-file ()
  "Choose and open a human-maintained Org file from this repository."
  (interactive)
  ;; 起始文档固定存在；模块清单则始终从 loader 的实际发现结果生成。
  (let* ((fixed-files '("README.org"
                        "bootstrap.org"
                        "docs/ROADMAP.org"))
         (module-files
          (mapcar (lambda (file)
                    (file-relative-name file maeiee-emacs-root))
                  (maeiee--module-files)))
         (relative-file
          (completing-read "配置文件: "
                           (append fixed-files module-files)
                           nil t)))
    (maeiee-config-menu--open-file relative-file)))
;; 打开固定文档与动态模块:1 ends here

;; [[file:../modules/33-config-management.org::*配置生命周期操作][配置生命周期操作:1]]
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
;; 配置生命周期操作:1 ends here

;; [[file:../modules/33-config-management.org::*组织面板并接入 Leader][组织面板并接入 Leader:1]]
(transient-define-prefix maeiee-config-menu ()
  "Open the Maeiee Emacs configuration control panel."
  [["开始"
    ("r" "README 总览"       maeiee-config-menu-open-readme)
    ("b" "bootstrap 自举"    maeiee-config-menu-open-bootstrap)
    ("d" "ROADMAP 路线图"    maeiee-config-menu-open-roadmap)]
   ["配置"
    ("f" "查找配置文件"       maeiee-config-menu-find-file)
    ("D" "打开配置目录"       maeiee-open-configuration)]
   ["管理"
    ("s" "保存当前文件"       save-buffer)
    ("e" "重载当前模块"       maeiee-reload-current-module)
    ("a" "Tangle 全部模块"    maeiee-tangle-all)
    ("c" "运行配置检查"       maeiee-config-menu-check)
    ("x" "运行环境诊断"       maeiee-config-menu-doctor)
    ("g" "打开 Magit"         maeiee-config-menu-magit-status)
    ("q" "关闭菜单"           transient-quit-one)]])

;; 保持原有 Leader 一级分类不变，只挂载一个 Maeiee 配置入口。
(maeiee-leader
  "m" '(maeiee-config-menu :which-key "Maeiee 配置"))
;; 组织面板并接入 Leader:1 ends here
