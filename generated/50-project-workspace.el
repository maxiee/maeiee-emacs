;; [[file:../modules/50-project-workspace.org::*用 project.el 建立工作边界][用 project.el 建立工作边界:1]]
(use-package project
  :ensure nil
  :custom
  ;; 切换项目后显示文件、搜索、Dired 与 Eshell 四个常用入口。
  (project-switch-commands
   '((project-find-file "Find file" ?f)
     (project-find-regexp "Find regexp" ?g)
     (project-dired "Dired" ?d)
     (project-eshell "Eshell" ?e))))

(with-eval-after-load 'general
  ;; General 就绪后建立稳定的项目二级菜单。
  (maeiee-leader
    "p" '(:ignore t :which-key "project")
    "p p" '(project-switch-project :which-key "switch")
    "p f" '(project-find-file :which-key "find file")
    "p g" '(project-find-regexp :which-key "grep")
    "p b" '(project-switch-to-buffer :which-key "buffer")
    "p d" '(project-dired :which-key "dired")))
;; 用 project.el 建立工作边界:1 ends here

;; [[file:../modules/50-project-workspace.org::*在左侧浏览项目文件树][在左侧浏览项目文件树:1]]
(use-package treemacs
  :commands (treemacs)
  :custom
  ;; 把项目文件树固定显示在左侧。
  (treemacs-position 'left)
  ;; 使用适合常见项目名称的初始宽度。
  (treemacs-width 32)
  ;; 第一次打开时定位并展开当前文件所在项目。
  (treemacs-follow-after-init t)
  (treemacs-expand-after-init t)
  :config
  ;; 编辑器切换文件时，让文件树同步选中当前文件。
  (treemacs-follow-mode 1)
  ;; 监听磁盘变化，及时刷新新建、删除或改名的文件。
  (treemacs-filewatch-mode 1))
;; 在左侧浏览项目文件树:1 ends here

;; [[file:../modules/50-project-workspace.org::*项目感知的文件树开关][项目感知的文件树开关:1]]
(defun maeiee-treemacs-toggle ()
  "Toggle the Treemacs sidebar, adding the current project when needed."
  (interactive)
  ;; 按键首次触发时才加载 Treemacs，避免增加无关启动工作。
  (require 'treemacs)
  ;; 已经显示时关闭；否则加入当前项目并显示文件树。
  (if (eq (treemacs-current-visibility) 'visible)
      (treemacs)
    (treemacs-add-and-display-current-project)))
;; 项目感知的文件树开关:1 ends here

;; [[file:../modules/50-project-workspace.org::*统一侧边栏导航与项目入口][统一侧边栏导航与项目入口:1]]
(use-package treemacs-evil
  :after (treemacs evil))

(with-eval-after-load 'general
  ;; 不增加新的 Leader 一级菜单，只扩展已有的项目菜单。
  (maeiee-leader
    "p t" '(maeiee-treemacs-toggle :which-key "toggle file tree")))
;; 统一侧边栏导航与项目入口:1 ends here
